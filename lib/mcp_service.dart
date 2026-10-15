import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:bluesky/app_bsky_feed_defs.dart' as bsky_feed;
import 'mcp_tools.dart';
import 'define.dart';

enum McpServerState { stopped, running }

// Dummy AbortSignal for MCP
class DummyAbortSignal implements AbortSignal {
  @override
  bool get aborted => false;
  @override
  Stream<void> get onAbort => const Stream.empty();
  @override
  dynamic get reason => null;
  @override
  void throwIfAborted() {}
}

class McpService extends ChangeNotifier {
  final McpTools mcpTools;

  // One McpServer per SSE session (Protocol supports a single transport)
  final Map<String, McpServer> _sessionServers = {};
  HttpServer? _httpServer;
  int mcpServerPort = 8080;

  McpServerState _mcpServerState = McpServerState.stopped;
  McpServerState get mcpServerState => _mcpServerState;

  // Holds a map of MCP tool names to callbacks (ToolFunction type)
  final Map<String, ToolFunction> _mcpToolMap = {};

  McpService({required this.mcpTools});

  Future<void> startMcpServer() async {
    if (_mcpServerState == McpServerState.running) return;
    print('MCP server starting...');
    try {
      _registerDefaultTools((name, callback) => _mcpToolMap[name] = callback);

      _httpServer =
          await HttpServer.bind(InternetAddress.anyIPv4, mcpServerPort);
      print('MCP HTTP server listening on port $mcpServerPort');
      _mcpServerState = McpServerState.running;
      notifyListeners();

      _handleRequests();
      print('MCP server started!');
    } catch (e, s) {
      print('MCP server start error: $e');
      print('Stack trace: $s');
    }
  }

  McpServer _createMcpServer() {
    final server = McpServer(
      Implementation(name: Define.title, version: Define.mcpVersion),
      options: McpServerOptions(),
    );
    _mcpToolMap.forEach((name, callback) {
      server.registerTool(name, callback: callback);
    });
    return server;
  }

  void _registerDefaultTools(void Function(String, ToolFunction) registerTool) {
    registerTool('get_recent_posts', (args, dynamic extra) async {
      print('MCP Tool Call: get_recent_posts with args: $args');
      try {
        final limit = args['limit'] ?? 3;
        final data = await mcpTools
            .getRecentPosts(limit is int ? limit : int.parse(limit.toString()));
        print('MCP Tool Call: get_recent_posts fetched ${data.length} posts');
        final contents = data.map((e) {
          final postJson = jsonDecode(e['post'] as String);
          final feedView = bsky_feed.FeedViewPost.fromJson(postJson);
          final author = feedView.post.author.handle;
          final record = feedView.post.record as Map<String, dynamic>;
          final text = record['text'] as String? ?? '';
          final indexed = e['indexed'];
          final uri = e['uri'];
          final image = _firstImageUrl(postJson);
          final imageLine = image == null ? '' : '\nImage: $image';
          return TextContent(
              text:
                  'Author: @$author\nTime: $indexed\nURI: $uri$imageLine\nContent: $text');
        }).toList();
        print('MCP Tool Call: get_recent_posts success');
        return CallToolResult(content: contents);
      } catch (e, s) {
        print('MCP Tool Call Error (get_recent_posts): $e\n$s');
        rethrow;
      }
    });

    registerTool('search_posts', (args, dynamic extra) async {
      final keyword = args['keyword']?.toString();
      final limit = args['limit'] ?? 10;
      final parsedLimit = limit is int ? limit : int.parse(limit.toString());

      DateTime? parseDate(String name) {
        final value = args[name];
        if (value == null) return null;
        return DateTime.tryParse(value.toString());
      }

      final start = parseDate('startDate');
      final end = parseDate('endDate');
      if ((args['startDate'] != null && start == null) ||
          (args['endDate'] != null && end == null)) {
        return CallToolResult(
          content: [
            TextContent(
                text: 'startDate and endDate must be valid ISO 8601 dates.')
          ],
          isError: true,
        );
      }
      if (start != null && end != null && start.isAfter(end)) {
        return CallToolResult(
          content: [TextContent(text: 'startDate must not be after endDate.')],
          isError: true,
        );
      }
      final pattern = args['pattern']?.toString();
      if (pattern != null && pattern.isNotEmpty) {
        try {
          RegExp(pattern, unicode: true);
        } on FormatException {
          return CallToolResult(
            content: [
              TextContent(text: 'pattern must be a valid regular expression.')
            ],
            isError: true,
          );
        }
      }

      final data = await mcpTools.searchPostsFiltered(
        keyword: keyword,
        pattern: pattern,
        start: start,
        end: end,
        limit: parsedLimit,
      );

      final contents = data.map((e) {
        final postJson = jsonDecode(e['post'] as String);
        final feedView = bsky_feed.FeedViewPost.fromJson(postJson);
        final author = feedView.post.author.handle;
        final record = feedView.post.record as Map<String, dynamic>;
        final text = record['text'] as String? ?? '';
        final indexed = e['indexed'];
        final uri = e['uri'];
        final image = _firstImageUrl(postJson);
        final imageLine = image == null ? '' : '\nImage: $image';
        return TextContent(
            text:
                'Author: @$author\nTime: $indexed\nURI: $uri$imageLine\nContent: $text');
      }).toList();
      return CallToolResult(content: contents);
    });

    registerTool('get_user_activity', (args, dynamic extra) async {
      String userId = args['userId'] ?? '';
      final limit = args['limit'] ?? 10;

      // If the userId is a handle (not starting with did:), try to resolve it to a DID
      if (userId.isNotEmpty && !userId.startsWith('did:')) {
        final resolvedDid = await mcpTools.resolveHandleToDid(userId);
        if (resolvedDid != null) {
          print('MCP: Resolved handle "$userId" to DID "$resolvedDid"');
          userId = resolvedDid;
        } else {
          print('MCP: Could not resolve handle "$userId"');
          return CallToolResult(
            content: [
              TextContent(
                  text: 'Handle "$userId" could not be found in local logs.')
            ],
            isError: true,
          );
        }
      }

      final data = await mcpTools.getUserActivity(
          userId, limit is int ? limit : int.parse(limit.toString()));
      final contents = data.map((e) {
        final postJson = jsonDecode(e['post'] as String);
        final feedView = bsky_feed.FeedViewPost.fromJson(postJson);
        final author = feedView.post.author.handle;
        final record = feedView.post.record as Map<String, dynamic>;
        final text = record['text'] as String? ?? '';
        final indexed = e['indexed'];
        final uri = e['uri'];
        final image = _firstImageUrl(postJson);
        final imageLine = image == null ? '' : '\nImage: $image';
        return TextContent(
            text:
                'Author: @$author\nTime: $indexed\nURI: $uri$imageLine\nContent: $text');
      }).toList();
      return CallToolResult(content: contents);
    });

    registerTool('get_monthly_activity_summary', (args, dynamic extra) async {
      final year = args['year'] ?? DateTime.now().year;
      final data = await mcpTools.getMonthlyActivitySummary(
          year is int ? year : int.parse(year.toString()));
      return CallToolResult(content: [TextContent(text: jsonEncode(data))]);
    });
  }

  String? _firstImageUrl(Map<String, dynamic> feedViewPostJson) {
    final post = feedViewPostJson['post'];
    if (post is! Map<String, dynamic>) {
      return null;
    }

    final embed = post['embed'];
    if (embed is! Map<String, dynamic> ||
        embed['\$type'] != 'app.bsky.embed.images#view') {
      return null;
    }

    final images = embed['images'];
    if (images is! List || images.isEmpty) {
      return null;
    }

    final firstImage = images.first;
    if (firstImage is! Map<String, dynamic>) {
      return null;
    }

    final fullsize = firstImage['fullsize'];
    if (fullsize is String && fullsize.isNotEmpty) {
      return fullsize;
    }

    final thumb = firstImage['thumb'];
    if (thumb is String && thumb.isNotEmpty) {
      return thumb;
    }

    return null;
  }

  void _handleRequests() async {
    final sseClients = <String, SseServerTransport>{};
    await for (HttpRequest request in _httpServer!) {
      final uri = request.uri;
      print(
          'MCP Incoming Request: ${request.method} ${uri.path}${uri.query != "" ? "?${uri.query}" : ""}');

      if (uri.path == '/') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.text
          ..write('MCP Server is running. Use /sse for MCP connection.')
          ..close();
        continue;
      }

      if (uri.path == '/sse' && request.method == 'GET') {
        _handleSseGet(request, sseClients);
      } else if ((uri.path == '/messages' || uri.path == '/sse') &&
          request.method == 'POST') {
        _handlePost(request, sseClients);
      } else if (request.method == 'OPTIONS') {
        _setCorsHeaders(request.response);
        request.response
          ..statusCode = 204
          ..close();
      } else {
        request.response
          ..statusCode = 404
          ..close();
      }
    }
  }

  void _handleSseGet(
      HttpRequest request, Map<String, SseServerTransport> sseClients) {
    print('MCP [SSE] GET (initial connection) received');
    _setCorsHeaders(request.response);

    final transport = SseServerTransport(
      response: request.response,
      messageEndpointPath: '/sse',
    );

    final sid = transport.sessionId;
    sseClients[sid] = transport;
    final server = _createMcpServer();
    _sessionServers[sid] = server;

    // response.done completes on detachSocket(), so track disconnects via
    // transport.onclose, which Protocol.connect overwrites.
    server.connect(transport).then((_) {
      print('MCP Server connected to transport for session: $sid');
      final protocolOnClose = transport.onclose;
      transport.onclose = () {
        protocolOnClose?.call();
        sseClients.remove(sid);
        _sessionServers.remove(sid);
        print('MCP SSE client disconnected: $sid');
      };
    }).catchError((e) {
      print('MCP Server connection error: $e');
      sseClients.remove(sid);
      _sessionServers.remove(sid);
    });
  }

  Future<void> _handlePost(
      HttpRequest request, Map<String, SseServerTransport> sseClients) async {
    final uri = request.uri;
    final sessionId = uri.queryParameters['sessionId'];
    final transport = sseClients[sessionId];

    _setCorsHeaders(request.response);

    if (transport == null) {
      if (sessionId != null) {
        request.response
          ..statusCode = 404
          ..write('Session not found')
          ..close();
      } else {
        await _handleProbePost(request);
      }
      return;
    }

    final body = await utf8.decoder.bind(request).join();
    try {
      final json = jsonDecode(body);
      print('MCP [POST] Message on ${uri.path} for $sessionId: $json');
      final message = JsonRpcMessage.fromJson(json);
      transport.onmessage?.call(message);
      request.response
        ..statusCode = 202
        ..close();
    } catch (e) {
      request.response
        ..statusCode = 400
        ..write('Invalid JSON-RPC message: $e')
        ..close();
    }
  }

  Future<void> _handleProbePost(HttpRequest request) async {
    final probeBody = await utf8.decoder.bind(request).join();
    print('MCP [POST] Probe Body: $probeBody');

    String responseBody = '{}';
    try {
      final json = jsonDecode(probeBody);
      final id = json['id'];
      final method = json['method'];

      if (method == 'initialize' && id != null) {
        responseBody = jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'protocolVersion': '2025-11-25',
            'capabilities': {
              'tools': {'listChanged': false},
              'resources': {'subscribe': false, 'listChanged': false},
              'prompts': {'listChanged': false},
              'logging': {},
            },
            'serverInfo': {'name': Define.title, 'version': Define.mcpVersion},
          },
        });
      } else if (method == 'tools/list' && id != null) {
        responseBody = jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'tools': [
              {
                'name': 'get_recent_posts',
                'description': 'Get recent posts from Bluesky',
                'inputSchema': {
                  'type': 'object',
                  'properties': {
                    'limit': {
                      'type': 'integer',
                      'description': 'Number of posts to fetch',
                      'default': 3
                    },
                  },
                },
              },
              {
                'name': 'search_posts',
                'description':
                    'Search Bluesky posts by keyword, date range, or regex pattern',
                'inputSchema': {
                  'type': 'object',
                  'properties': {
                    'keyword': {
                      'type': 'string',
                      'description': 'Search keyword'
                    },
                    'startDate': {
                      'type': 'string',
                      'description': 'Start date (ISO8601, optional)'
                    },
                    'endDate': {
                      'type': 'string',
                      'description': 'End date (ISO8601, optional)'
                    },
                    'pattern': {
                      'type': 'string',
                      'description': 'Regular expression pattern (optional)'
                    },
                    'limit': {
                      'type': 'integer',
                      'description': 'Maximum number of results',
                      'default': 10
                    },
                  },
                },
              },
              {
                'name': 'get_user_activity',
                'description': 'Get activity for a specific user',
                'inputSchema': {
                  'type': 'object',
                  'properties': {
                    'userId': {
                      'type': 'string',
                      'description': 'User ID or handle'
                    },
                    'limit': {
                      'type': 'integer',
                      'description': 'Number of items to fetch',
                      'default': 10
                    },
                  },
                  'required': ['userId'],
                },
              },
              {
                'name': 'get_monthly_activity_summary',
                'description':
                    'Get a monthly activity summary (post counts, top hashtags) for a specific year',
                'inputSchema': {
                  'type': 'object',
                  'properties': {
                    'year': {
                      'type': 'integer',
                      'description': 'Target year (e.g. 2025)'
                    },
                  },
                  'required': ['year'],
                },
              },
            ],
          },
        });
      } else if (method == 'prompts/list' && id != null) {
        responseBody = jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {'prompts': []}
        });
      } else if (method == 'resources/list' && id != null) {
        responseBody = jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {'resources': []}
        });
      } else if (method == 'tools/call' && id != null) {
        final params = json['params'] ?? {};
        final toolName = params['name'];
        final toolArgs = params['arguments'] ?? {};
        final callback = _mcpToolMap[toolName];
        if (callback != null) {
          try {
            print('MCP [POST] Executing tool: $toolName');
            final result = await (callback as dynamic)(toolArgs, null);
            responseBody = jsonEncode(
                {'jsonrpc': '2.0', 'id': id, 'result': result.toJson()});
          } catch (e, s) {
            print('MCP [POST] Tool execution error: $e\n$s');
            responseBody = jsonEncode({
              'jsonrpc': '2.0',
              'id': id,
              'error': {'code': -32603, 'message': 'Internal error: $e'},
            });
          }
        } else {
          responseBody = jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'error': {'code': -32601, 'message': 'Tool not found: $toolName'},
          });
        }
      } else if (method == 'ping' && id != null) {
        responseBody = jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': {}});
      } else if (method == 'notifications/initialized') {
        responseBody = '';
      }
    } catch (e) {
      print('MCP [POST] Probe JSON parse error: $e');
    }

    request.response
      ..headers.contentType = ContentType.json
      ..statusCode = 200;
    _setCorsHeaders(request.response);
    request.response
      ..write(responseBody)
      ..close();
  }

  Future<void> stopMcpServer() async {
    if (_mcpServerState == McpServerState.stopped) return;
    _mcpServerState = McpServerState.stopped;
    notifyListeners();
    if (_httpServer != null) {
      try {
        await _httpServer!.close(force: true);
        print('[MCP] HttpServer shutdown complete');
      } catch (e, st) {
        print('[MCP] HttpServer shutdown error: $e\n$st');
      }
      _httpServer = null;
    }
    final servers = _sessionServers.values.toList();
    _sessionServers.clear();
    for (final server in servers) {
      await server.close();
    }
  }

  Future<void> toggleMcpServer() async {
    if (_mcpServerState == McpServerState.running) {
      await stopMcpServer();
    } else {
      await startMcpServer();
    }
  }

  void _setCorsHeaders(HttpResponse response) {
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
  }
}
