import 'dart:convert';

import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/atproto.dart' as atproto;
import 'package:bluesky/core.dart' as bluesky_core;
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrpc/xrpc.dart' as xrpc;

import 'database.dart';

class ActorModel {
  final String service;
  final String identifier;
  final String did;

  bluesky_core.Session? session;
  bluesky.ActorProfile? profile;

  ActorModel({
    required this.service,
    required this.identifier,
    required bluesky_core.Session this.session,
  }) : did = session.did;

  ActorModel.fromJson(Map json)
      : service = json['service'],
        identifier = json['identifier'],
        did = json['did'],
        session = json['session'] != null
            ? bluesky_core.Session.fromJson(json['session'])
            : null,
        profile = json['profile'] != null
            ? bluesky.ActorProfile.fromJson(json['profile'])
            : null;

  Map toJson() => {
        'service': service,
        'identifier': identifier,
        'did': did,
        'session': session?.toJson(),
        'profile': profile?.toJson(),
      };

  bool isSessionValid() {
    if (session == null) {
      return false;
    }

    final accessJwt =
        JWT.decode(session!.accessJwt).payload as Map<String, dynamic>;
    final accessExp = DateTime.fromMillisecondsSinceEpoch(
      (accessJwt['exp'] as int) * 1000,
    );

    final now = DateTime.now().toUtc();
    return !now.isAfter(accessExp);
  }
}

class Model extends ChangeNotifier {
  Model({required this.database});

  final AppDatabase database;

  PackageInfo? _packageInfo;
  PackageInfo? get packageInfo => _packageInfo;

  ActorModel? _currentActor;
  ActorModel? get currentActor => _currentActor;

  int? _searchYear;
  int? get searchYear => _searchYear;
  int? _searchMonth;
  int? get searchMonth => _searchMonth;
  int? _searchDay;
  int? get searchDay => _searchDay;
  String? _searchKeyword;
  String? get searchKeyword => _searchKeyword;

  int _progress = 0;
  int get progress => _progress;
  String _progressMessage = '';
  String get progressMessage => _progressMessage;

  Future updateSharedPrefrences() async {
    final data = json.encode(toJson());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', data);
  }

  Future syncDataWithProvider() async {
    _packageInfo = await PackageInfo.fromPlatform();

    countDatePosts();

    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('settings');
    if (data != null) {
      fromJson(json.decode(data));

      notifyListeners();
    }
  }

  void fromJson(Map json) {
    if (json['actor'] != null) {
      _currentActor = ActorModel.fromJson(json['actor']);
    }

    notifyListeners();
  }

  Map toJson() => {
        'actor': _currentActor?.toJson(),
      };

  void setSearchYear(int? year) {
    _searchYear = year;
    _searchMonth = null;
    _searchDay = null;

    notifyListeners();
  }

  void setSearchMonth(int? month) {
    _searchMonth = month;
    _searchDay = null;

    notifyListeners();
  }

  void setSearchDay(int? day) {
    _searchDay = day;

    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;

    notifyListeners();
  }

  SimpleSelectStatement filter() {
    final query = database.posts.select();
    if (_searchYear != null) {
      if (_searchMonth != null) {
        if (_searchDay != null) {
          query.where((tbl) => tbl.indexed.isBetweenValues(
                DateTime.utc(_searchYear!, _searchMonth!, _searchDay!),
                DateTime.utc(
                    _searchYear!, _searchMonth!, _searchDay!, 23, 59, 59),
              ));
        } else {
          query.where((tbl) => tbl.indexed.isBetweenValues(
                DateTime.utc(_searchYear!, _searchMonth!, 1),
                DateTime.utc(_searchYear!, _searchMonth! + 1, 0, 23, 59, 59),
              ));
        }
      } else {
        query.where((tbl) => tbl.indexed.isBetweenValues(
              DateTime.utc(_searchYear!, 1, 1),
              DateTime.utc(_searchYear!, 12, 31, 23, 59, 59),
            ));
      }
    }
    if (_searchKeyword != null) {
      query.where((tbl) => tbl.post.like('%$_searchKeyword%'));
    }

    return query;
  }

  final Map<int, int> _countByDate = {};
  Map<int, int> get countByDate => _countByDate;

  void countDatePosts() async {
    final count = database.posts.uri.count();
    final query = database.posts.selectOnly()
      ..addColumns([database.posts.indexed.date, count])
      ..groupBy([database.posts.indexed.date]);

    final result = await query.get();
    for (final row in result) {
      final date = DateTime.parse(row.rawData.read<String>('c0'));
      final count = row.rawData.read<int>('c1');

      final day = date.year * 10000 + date.month * 100 + date.day;
      _countByDate[day] = count;
      final month = date.year * 10000 + date.month * 100;
      _countByDate[month] = (_countByDate[month] ?? 0) + count;
      final year = date.year * 10000;
      _countByDate[year] = (_countByDate[year] ?? 0) + count;
    }

    createMenuTree();

    notifyListeners();
  }

  DateTime get firstDay {
    final first = _countByDate.keys
        .where((key) => key % 100 != 0)
        .reduce((value, element) => value < element ? value : element);
    return DateTime(first ~/ 10000, (first % 10000) ~/ 100, first % 100);
  }

  DateTime get lastDay {
    final last = _countByDate.keys
        .where((key) => key % 100 != 0)
        .reduce((value, element) => value > element ? value : element);
    return DateTime(last ~/ 10000, (last % 10000) ~/ 100, last % 100);
  }

  TreeNode? _rootTree;
  TreeNode? get roorTree => _rootTree;

  void createMenuTree() {
    _rootTree = TreeNode();

    final archivesNode = TreeNode(key: 'Archives');
    _rootTree!.add(archivesNode);

    final yearNodes = <int, TreeNode<dynamic>>{};

    for (final date in _countByDate.keys) {
      final year = date ~/ 10000;
      final month = (date % 10000) ~/ 100;
      final day = date % 100;
      if (day > 0) {
        continue;
      }

      final yearNode = yearNodes.putIfAbsent(year, () {
        final count = _countByDate[year * 10000];
        final node = TreeNode(key: '$year ($count)', data: DateTime(year));
        archivesNode.add(node);
        return node;
      });

      if (month > 0) {
        final count = _countByDate[year * 10000 + month * 100];
        final node =
            TreeNode(key: '$month ($count)', data: DateTime(year, month));
        yearNode.add(node);
      }
    }

    notifyListeners();
  }

  void setProgress(int value, {String? message}) {
    _progress = value;
    _progressMessage = message ?? '';

    notifyListeners();
  }

  Future<bluesky_core.Session> createSession(
      String newService, String newIdentifier, String newPassword) async {
    final resSession = await atproto.createSession(
      service: newService,
      identifier: newIdentifier,
      password: newPassword,
    );
    switch (resSession.status.code) {
      case 200:
      case 204:
        break;
      default:
        throw Exception(resSession.status.message);
    }
    return resSession.data;
  }

  Future signin(
      String newService, String newIdentifier, String newPassword) async {
    try {
      // newIdentifire が.を含まない場合、serviceを追加
      if (!newIdentifier.contains('.')) {
        newIdentifier = '$newIdentifier.$newService';
      }

      final session =
          await createSession(newService, newIdentifier, newPassword);

      _currentActor = ActorModel(
        service: newService,
        identifier: newIdentifier,
        session: session,
      );

      final bsky = await getBluesky(_currentActor!);
      final resProfile = await bsky.actor.getProfile(actor: session.did);
      _currentActor!.profile = resProfile.data;

      updateSharedPrefrences();
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('signin Exception details:\n $e');
        print('Stack trace:\n $s');
      }
      rethrow;
    }
  }

  // blueskyサインアウト処理
  Future signout() async {
    if (_currentActor == null) {
      return;
    }

    try {
      // セッションを削除
      await atproto.deleteSession(
        service: _currentActor!.service,
        refreshJwt: _currentActor!.session!.refreshJwt,
      );
      // カレントなら削除
      if (_currentActor?.session?.did == _currentActor!.session!.did) {
        _currentActor = null;
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('signout Exception details:\n $e');
        print('Stack trace:\n $s');
      }
      rethrow;
    }

    notifyListeners();
  }

  Future<bluesky.Bluesky> getBluesky(ActorModel actor) async {
    if (actor.session == null) {
      throw Exception('not signin');
    }

    if (!actor.isSessionValid()) {
      final newSession = await atproto.refreshSession(
        service: actor.service,
        refreshJwt: actor.session!.refreshJwt,
      );

      switch (newSession.status.code) {
        case 200:
        case 204:
          break;
        default:
          throw Exception(newSession.status.message);
      }

      actor.session = newSession.data;

      updateSharedPrefrences();
      notifyListeners();
    }

    return bluesky.Bluesky.fromSession(actor.session!, service: actor.service);
  }

  DateTime? _lastSync;
  String? _tailCursor;

  Future syncFeed() async {
    // _tailCursor 以前を取得
    do {
      _tailCursor = await getFeed(cursor: _tailCursor);
    } while (_tailCursor != null && _tailCursor!.isNotEmpty);
    // 新しい野から取得
  }

  Future<String?> getFeed({String? cursor}) async {
    final methodId = xrpc.NSID.create(
      'feed.bsky.app',
      'getAuthorFeed',
    );
    final service = _currentActor!.service;
    final accessJwt = _currentActor!.session!.accessJwt;

    try {
      final response = await xrpc.query<String>(
        methodId,
        service: service,
        headers: {'Authorization': 'Bearer $accessJwt'},
        parameters: {
          'actor': _currentActor!.did,
          'limit': 100,
          'cursor': cursor ?? '',
        },
      );

      final status = response.status;

      if (kDebugMode) {
        print('code:${status.code} message:${status.message}');
        print(response.request.toString());
      }

      final feedData = bluesky.Feed.fromJson(jsonDecode(response.data));
      cursor = feedData.cursor;

      if (kDebugMode) {
        print('feeds:${feedData.feed.length} cursor:$cursor');
      }

      if (kDebugMode) {
        print(feedData.feed.length);
      }
      for (var feedView in feedData.feed) {
        final post = feedView.post;
        await database.into(database.posts).insert(
              PostsCompanion.insert(
                uri: post.uri.toString(),
                authorDid: post.author.did,
                indexed: post.indexedAt,
                replyDid: '',
                havEmbedImages: false,
                havEmbedExternal: false,
                havEmbedRecord: false,
                reasonRepost: false,
                post: jsonEncode(feedView.toJson()),
              ),
            );
      }
    } on xrpc.XRPCException catch (e) {
      final status = e.response.status;

      if (kDebugMode) {
        print('${status.code} ${status.message}');
        print(e.response.request.toString());
        print(e.response.data.toJson());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    return cursor;
  }
}
