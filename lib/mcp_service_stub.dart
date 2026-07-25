import 'package:flutter/foundation.dart';

import 'mcp_tools.dart';

enum McpServerState { stopped, running }

class McpService extends ChangeNotifier {
  McpService({required this.mcpTools});

  final McpTools mcpTools;

  int mcpServerPort = 8080;

  McpServerState get mcpServerState => McpServerState.stopped;

  Future<void> startMcpServer() async {}

  Future<void> stopMcpServer() async {}

  Future<void> toggleMcpServer() async {}
}
