import 'dart:convert';
import 'dart:io';

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
import 'package:http/http.dart' as http;

import 'database.dart';
import 'define.dart';

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
    final accessExp =
        DateTime.fromMillisecondsSinceEpoch((accessJwt['exp'] as int) * 1000);

    if (kDebugMode) {
      print(accessJwt);
      print(accessExp.toLocal());
    }

    final now = DateTime.now().toUtc();
    return !now.isAfter(accessExp);
  }
}

class Model extends ChangeNotifier {
  Model({required this.database});

  final AppDatabase database;

  String? _migrationState;
  String? get migrationState => _migrationState;

  PackageInfo? _packageInfo;
  PackageInfo? get packageInfo => _packageInfo;
  String get version => 'v${_packageInfo!.version}';
  String get versionPlusBuildNumber => 'v${_packageInfo!.version}'
      '+${_packageInfo!.buildNumber}';

  String? _githubReleaseVersion;
  String? get githubReleaseVersion => _githubReleaseVersion;

  bool get newRelease =>
      _packageInfo != null &&
      _githubReleaseVersion != null &&
      _githubReleaseVersion != version;

  ActorModel? _currentActor;
  ActorModel? get currentActor => _currentActor;

  DateTime? _lastSync;
  DateTime? get lastSync => _lastSync;
  Map<String, String?> _tailCursors = {};

  bool _visibleFilterMenu = true;
  bool get visibleFilterMenu => _visibleFilterMenu;

  int? _searchYear;
  int? get searchYear => _searchYear;
  int? _searchMonth;
  int? get searchMonth => _searchMonth;
  int? _searchDay;
  int? get searchDay => _searchDay;
  bool _regExpSearch = false;
  bool get regExpSearch => _regExpSearch;

  String? _searchKeyword;
  String? get searchKeyword => _searchKeyword;

  bool _canNextSearch = false;
  bool get canNextSearch => _canNextSearch;
  bool _canPrevSearch = false;
  bool get canPrevSearch => _canPrevSearch;

  final Map<VisibleType, VisibleMode> _visible = {
    VisibleType.plane: VisibleMode.show,
    VisibleType.reply: VisibleMode.show,
    VisibleType.repost: VisibleMode.show,
    VisibleType.linkcard: VisibleMode.show,
    VisibleType.image: VisibleMode.show,
    VisibleType.video: VisibleMode.show,
  };

  SortOrder _sortOrder = SortOrder.desc;
  SortOrder get sortOrder => _sortOrder;

  bool _visibleImage = true;
  bool get visibleImage => _visibleImage;

  double _volume = 0.0;
  double get volume => _volume;

  int _progress = 0;
  int get progress => _progress;
  String _progressMessage = '';
  String get progressMessage => _progressMessage;

  final Map<int, int> _countByDate = {};
  Map<int, int> get countByDate => _countByDate;

  TreeNode _rootTree = TreeNode.root();
  TreeNode get rootTree => _rootTree;

  Future updateSharedPrefrences() async {
    final data = jsonEncode(toJson());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', data);
  }

  Future syncDataWithProvider() async {
    _packageInfo = await PackageInfo.fromPlatform();
    await fetchReleases();

    countDatePosts();

    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('settings');
    if (data != null) {
      fromJson(jsonDecode(data));

      if (kDebugMode) {
        print(_currentActor?.session?.toJson());
      }

      notifyListeners();
    }
  }

  void fromJson(Map json) {
    for (final type in VisibleType.values) {
      if (json['visible.${type.name}'] != null) {
        _visible[type] = VisibleMode.values.firstWhere(
            (element) => element.name == json['visible.${type.name}']);
      }
    }
    if (json['regExpSearch'] != null) {
      _regExpSearch = json['regExpSearch'];
    }
    if (json['sortOrder'] != null) {
      _sortOrder = SortOrder.values
          .firstWhere((element) => element.toString() == json['sortOrder']);
    }
    if (json['actor'] != null) {
      _currentActor = ActorModel.fromJson(json['actor']);
    }
    if (json['lastSync'] != null) {
      try {
        _lastSync = DateTime.parse(json['lastSync']);
      } catch (e) {
        _lastSync = null;
      }
    }
    if (json['tailCursors'] != null) {
      final tails = jsonDecode(json['tailCursors']);
      if (tails is Map) {
        final Map<String, String?> castedMap = {};
        tails.forEach((k, v) {
          castedMap[k.toString()] = v as String?;
        });
        _tailCursors = castedMap;
      }
    } else if (json['tailCursor'] != null && _currentActor != null) {
      _tailCursors[_currentActor!.did] = json['tailCursor'];
    }
    if (json['volume'] != null) {
      _volume = json['volume'];
    }
    if (json['visibleImage'] != null) {
      _visibleImage = json['visibleImage'];
    }

    notifyListeners();
  }

  Map visibleToJson() {
    Map json = {};
    for (final type in VisibleType.values) {
      if (_visible[type] != null) {
        json['visible.${type.name}'] = _visible[type]!.name;
      }
    }
    return json;
  }

  Map toJson() => {
        ...visibleToJson(),
        'regExpSearch': _regExpSearch,
        'sortOrder': _sortOrder.toString(),
        'actor': _currentActor?.toJson(),
        'lastSync': _lastSync?.toString(),
        'tailCursors': jsonEncode(_tailCursors),
        'volume': _volume,
        'visibleImage': _visibleImage,
      };

  VisibleMode visible(VisibleType type) {
    if (_visible.values.contains(VisibleMode.only)) {
      return _visible[type] == VisibleMode.only
          ? VisibleMode.only
          : VisibleMode.disable;
    }
    return _visible[type] ?? VisibleMode.show;
  }

  setMigrationState(String? state) {
    _migrationState = state;
    notifyListeners();
  }

  void setVisible(VisibleType type, VisibleMode mode) {
    _visible[type] = mode;

    for (final key in _visible.keys) {
      if (key != type && _visible[key] == VisibleMode.only) {
        _visible[key] = VisibleMode.show;
      }
    }

    updateSharedPrefrences();
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;

    updateSharedPrefrences();
    notifyListeners();
  }

  double toggleVolume() {
    _volume = _volume == 0 ? 1 : 0;
    notifyListeners();
    return _volume;
  }

  void toggleImage() {
    _visibleImage = !_visibleImage;

    notifyListeners();
  }

  void toggleVisibleFilterMenu() {
    _visibleFilterMenu = !_visibleFilterMenu;

    notifyListeners();
  }

  void clearSearchRange() async {
    _searchYear = null;
    _searchMonth = null;
    _searchDay = null;

    _canNextSearch = await getNextSearch();
    _canPrevSearch = await getPrevSearch();

    notifyListeners();
  }

  void setSearchYear(int year) async {
    _searchYear = year;
    _searchMonth = null;
    _searchDay = null;

    final first = firstDay;
    final last = lastDay;
    final search = DateTime(_searchYear!);
    final focused =
        last.isBefore(first.isAfter(search) ? first : search) ? last : search;
    _searchYear = focused.year;

    _canNextSearch = await getNextSearch();
    _canPrevSearch = await getPrevSearch();

    notifyListeners();
  }

  void setSearchMonth(int year, int month) async {
    _searchYear = year;
    _searchMonth = month;
    _searchDay = null;

    final first = firstDay;
    final last = lastDay;
    final search = DateTime(_searchYear!, _searchMonth!);
    final focused =
        last.isBefore(first.isAfter(search) ? first : search) ? last : search;
    _searchYear = focused.year;
    _searchMonth = focused.month;

    _canNextSearch = await getNextSearch();
    _canPrevSearch = await getPrevSearch();

    notifyListeners();
  }

  void setSearchDay(int year, int month, int day) async {
    _searchYear = year;
    _searchMonth = month;
    _searchDay = day;

    final first = firstDay;
    final last = lastDay;
    final search = DateTime(_searchYear!, _searchMonth!, _searchDay!);
    final focused =
        last.isBefore(first.isAfter(search) ? first : search) ? last : search;
    _searchYear = focused.year;
    _searchMonth = focused.month;
    _searchDay = focused.day;

    _canNextSearch = await getNextSearch();
    _canPrevSearch = await getPrevSearch();

    notifyListeners();
  }

  Future<bool> getNextSearch() async {
    if (_searchYear == null) {
      return false;
    }
    final post = await (database.select(database.posts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();
    if (post == null) {
      return false;
    }
    if (_searchDay != null) {
      return post.indexed
          .isAfter(DateTime(_searchYear!, _searchMonth!, _searchDay!));
    } else if (_searchMonth != null) {
      return post.indexed.isAfter(DateTime(_searchYear!, _searchMonth!, 30));
    }
    return post.indexed.isAfter(DateTime(_searchYear!, 12, 31));
  }

  Future<bool> getPrevSearch() async {
    if (_searchYear == null) {
      return false;
    }
    final post = await (database.select(database.posts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.asc)
          ])
          ..limit(1))
        .getSingleOrNull();
    if (post == null) {
      return false;
    }
    if (_searchDay != null) {
      return post.indexed
          .isBefore(DateTime(_searchYear!, _searchMonth!, _searchDay!));
    } else if (_searchMonth != null) {
      return post.indexed.isBefore(DateTime(_searchYear!, _searchMonth!, 1));
    }
    return post.indexed.isBefore(DateTime(_searchYear!, 1, 1));
  }

  void nextSearch() async {
    if (_searchDay != null) {
      final next = DateTime(_searchYear!, _searchMonth!, _searchDay!)
          .add(const Duration(days: 1));
      setSearchDay(next.year, next.month, next.day);
    } else if (_searchMonth != null) {
      var nextYear = _searchYear!;
      var nextMonth = _searchMonth! + 1;
      if (nextMonth > 12) {
        nextYear = nextYear + 1;
        nextMonth = 1;
      }
      setSearchMonth(nextYear, nextMonth);
    } else if (_searchYear != null) {
      setSearchYear(_searchYear! + 1);
    }
  }

  void prevSearch() async {
    if (_searchDay != null) {
      final prev = DateTime(_searchYear!, _searchMonth!, _searchDay!)
          .subtract(const Duration(days: 1));
      setSearchDay(prev.year, prev.month, prev.day);
    } else if (_searchMonth != null) {
      var prevYear = _searchYear!;
      var prevMonth = _searchMonth! - 1;
      if (_searchMonth! < 1) {
        prevYear = prevYear - 1;
        prevMonth = 12;
      }
      setSearchMonth(prevYear, prevMonth);
    } else if (_searchYear != null) {
      setSearchYear(_searchYear! - 1);
    }
  }

  void toggleRegExpSearch() {
    _regExpSearch = !_regExpSearch;

    updateSharedPrefrences();
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;

    notifyListeners();
  }

  SimpleSelectStatement filterSearch() {
    final query = database.posts.select();

    if (_searchYear != null) {
      if (_searchMonth != null) {
        if (_searchDay != null) {
          query.where((tbl) => tbl.indexed.isBetweenValues(
                DateTime(_searchYear!, _searchMonth!, _searchDay!),
                DateTime(_searchYear!, _searchMonth!, _searchDay!, 23, 59, 59),
              ));
        } else {
          query.where((tbl) => tbl.indexed.isBetweenValues(
                DateTime(_searchYear!, _searchMonth!, 1),
                DateTime(_searchYear!, _searchMonth! + 1, 0, 23, 59, 59),
              ));
        }
      } else {
        query.where((tbl) => tbl.indexed.isBetweenValues(
              DateTime(_searchYear!, 1, 1),
              DateTime(_searchYear!, 12, 31, 23, 59, 59),
            ));
      }
    }

    if (_searchKeyword != null) {
      if (_regExpSearch) {
        query.where((tbl) => tbl.post.regexp('$_searchKeyword', unicode: true));
      } else {
        query.where((tbl) => tbl.post.like('%$_searchKeyword%'));
      }
    }

    if (_visible.values.contains(VisibleMode.only)) {
      for (var MapEntry(key: key, value: value) in _visible.entries) {
        if (value == VisibleMode.only) {
          switch (key) {
            case VisibleType.plane:
              // repost, quote, linkcard, image, video
              query.where((tbl) =>
                  tbl.reasonRepost.equals(false) &
                  tbl.havEmbedRecord.equals(false) &
                  tbl.havEmbedRecordWithMedia.equals(false) &
                  tbl.havEmbedExternal.equals(false) &
                  tbl.havEmbedImages.equals(false) &
                  tbl.havEmbedVideo.equals(false));
              break;
            case VisibleType.reply:
              query.where((tbl) => tbl.replyDid.length.isBiggerThanValue(0));
              break;
            case VisibleType.repost:
              query.where((tbl) => tbl.reasonRepost.equals(true));
              break;
            case VisibleType.quote:
              query.where((tbl) =>
                  tbl.havEmbedRecord.equals(true) |
                  tbl.havEmbedRecordWithMedia.equals(true));
              break;
            case VisibleType.linkcard:
              query.where((tbl) => tbl.havEmbedExternal.equals(true));
              break;
            case VisibleType.image:
              query.where((tbl) => tbl.havEmbedImages.equals(true));
              break;
            case VisibleType.video:
              query.where((tbl) => tbl.havEmbedVideo.equals(true));
              break;
          }
        }
      }
    } else {
      for (var MapEntry(key: key, value: value) in _visible.entries) {
        if (value == VisibleMode.hide) {
          switch (key) {
            case VisibleType.plane:
              // repost, quote, linkcard, image, video
              query.where((tbl) =>
                  tbl.reasonRepost.equals(true) |
                  tbl.havEmbedRecord.equals(true) |
                  tbl.havEmbedRecordWithMedia.equals(true) |
                  tbl.havEmbedExternal.equals(true) |
                  tbl.havEmbedImages.equals(true) |
                  tbl.havEmbedVideo.equals(true));
              break;
            case VisibleType.reply:
              query.where((tbl) => tbl.replyDid.equals(''));
              break;
            case VisibleType.repost:
              query.where((tbl) => tbl.reasonRepost.equals(false));
              break;
            case VisibleType.quote:
              query.where((tbl) =>
                  tbl.havEmbedRecord.equals(false) &
                  tbl.havEmbedRecordWithMedia.equals(false));
              break;
            case VisibleType.linkcard:
              query.where((tbl) => tbl.havEmbedExternal.equals(false));
              break;
            case VisibleType.image:
              query.where((tbl) => tbl.havEmbedImages.equals(false));
              break;
            case VisibleType.video:
              query.where((tbl) => tbl.havEmbedVideo.equals(false));
              break;
          }
        }
      }
    }

    return query
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.indexed,
            mode: _sortOrder == SortOrder.asc
                ? OrderingMode.asc
                : OrderingMode.desc)
      ]);
  }

  Stream<int?> filterSearchWatchCount() {
    // SimpleSelectStatement<$PostsTable, Post>
    // JoinedSelectStatement<$PostsTable, Post>
    final itemCount = database.posts.id.count();
    final query = database.posts.selectOnly()..addColumns([itemCount]);

    if (_searchYear != null) {
      if (_searchMonth != null) {
        if (_searchDay != null) {
          query.where(database.posts.indexed.isBetweenValues(
            DateTime(_searchYear!, _searchMonth!, _searchDay!),
            DateTime(_searchYear!, _searchMonth!, _searchDay!, 23, 59, 59),
          ));
        } else {
          query.where(database.posts.indexed.isBetweenValues(
            DateTime(_searchYear!, _searchMonth!, 1),
            DateTime(_searchYear!, _searchMonth! + 1, 0, 23, 59, 59),
          ));
        }
      } else {
        query.where(database.posts.indexed.isBetweenValues(
          DateTime(_searchYear!, 1, 1),
          DateTime(_searchYear!, 12, 31, 23, 59, 59),
        ));
      }
    }

    if (_searchKeyword != null) {
      if (_regExpSearch) {
        query.where(
            database.posts.post.regexp('$_searchKeyword', unicode: true));
      } else {
        query.where(database.posts.post.like('%$_searchKeyword%'));
      }
    }

    if (_visible.values.contains(VisibleMode.only)) {
      for (var MapEntry(key: key, value: value) in _visible.entries) {
        if (value == VisibleMode.only) {
          switch (key) {
            case VisibleType.plane:
              // repost, quote, linkcard, image, video
              query.where(database.posts.reasonRepost.equals(false) &
                  database.posts.havEmbedRecord.equals(false) &
                  database.posts.havEmbedRecordWithMedia.equals(false) &
                  database.posts.havEmbedExternal.equals(false) &
                  database.posts.havEmbedImages.equals(false) &
                  database.posts.havEmbedVideo.equals(false));
              break;
            case VisibleType.reply:
              query.where(database.posts.replyDid.length.isBiggerThanValue(0));
              break;
            case VisibleType.repost:
              query.where(database.posts.reasonRepost.equals(true));
              break;
            case VisibleType.quote:
              query.where(database.posts.havEmbedRecord.equals(true) |
                  database.posts.havEmbedRecordWithMedia.equals(true));
              break;
            case VisibleType.linkcard:
              query.where(database.posts.havEmbedExternal.equals(true));
              break;
            case VisibleType.image:
              query.where(database.posts.havEmbedImages.equals(true));
              break;
            case VisibleType.video:
              query.where(database.posts.havEmbedVideo.equals(true));
              break;
          }
        }
      }
    } else {
      for (var MapEntry(key: key, value: value) in _visible.entries) {
        if (value == VisibleMode.hide) {
          switch (key) {
            case VisibleType.plane:
              // repost, quote, linkcard, image, video
              query.where(database.posts.reasonRepost.equals(true) |
                  database.posts.havEmbedRecord.equals(true) |
                  database.posts.havEmbedRecordWithMedia.equals(true) |
                  database.posts.havEmbedExternal.equals(true) |
                  database.posts.havEmbedImages.equals(true) |
                  database.posts.havEmbedVideo.equals(true));
              break;
            case VisibleType.reply:
              query.where(database.posts.replyDid.equals(''));
              break;
            case VisibleType.repost:
              query.where(database.posts.reasonRepost.equals(false));
              break;
            case VisibleType.quote:
              query.where(database.posts.havEmbedRecord.equals(false) &
                  database.posts.havEmbedRecordWithMedia.equals(false));
              break;
            case VisibleType.linkcard:
              query.where(database.posts.havEmbedExternal.equals(false));
              break;
            case VisibleType.image:
              query.where(database.posts.havEmbedImages.equals(false));
              break;
            case VisibleType.video:
              query.where(database.posts.havEmbedVideo.equals(false));
              break;
          }
        }
      }
    }

    return query.map((row) => row.read(itemCount)).watchSingle();
  }

  Future countDatePosts() async {
    _countByDate.clear();

    final idCount = database.posts.uri.count();
    final query = database.posts.selectOnly()
      ..addColumns([database.posts.indexed.date, idCount])
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
    notifyListeners();

    createMenuTree();
  }

  DateTime get focusedDay {
    final first = firstDay;
    final last = lastDay;

    if (_searchDay != null) {
      final focused = DateTime(_searchYear!, _searchMonth!, _searchDay!);
      return first.isAfter(focused)
          ? first
          : last.isBefore(focused)
              ? last
              : focused;
    }
    if (_searchMonth != null) {
      final focused = DateTime(_searchYear!, _searchMonth!);
      return first.isAfter(focused)
          ? first
          : last.isBefore(focused)
              ? last
              : focused;
    }
    if (_searchYear != null) {
      final focused = DateTime(_searchYear!);
      return first.isAfter(focused)
          ? first
          : last.isBefore(focused)
              ? last
              : focused;
    }
    return lastDay;
  }

  DateTime get firstDay {
    if (_countByDate.isEmpty) {
      return DateTime.now();
    }
    final first = _countByDate.keys
        .where((key) => key % 100 != 0)
        .reduce((value, element) => value < element ? value : element);
    return DateTime(first ~/ 10000, (first % 10000) ~/ 100, first % 100);
  }

  DateTime get lastDay {
    if (_countByDate.isEmpty) {
      return DateTime.now();
    }
    final last = _countByDate.keys
        .where((key) => key % 100 != 0)
        .reduce((value, element) => value > element ? value : element);
    return DateTime(last ~/ 10000, (last % 10000) ~/ 100, last % 100);
  }

  Future fetchReleases() async {
    final response = await http.get(Uri.parse(Define.githubReleasesApi));
    if (response.statusCode == 200) {
      List<dynamic> releases = jsonDecode(response.body);
      for (var release in releases) {
        _githubReleaseVersion = release['name'];
        if (kDebugMode) {
          print('github releases $_githubReleaseVersion');
        }
        return;
      }
    } else {
      if (kDebugMode) {
        print('Failed to fetch releases');
      }
    }
  }

  Future createMenuTree() async {
    final tree = TreeNode.root();

    final yearNodes = <int, TreeNode<dynamic>>{};

    final sortedKeys = _countByDate.keys.toList()..sort((a, b) => b - a);
    for (final date in sortedKeys) {
      final year = date ~/ 10000;
      final month = (date % 10000) ~/ 100;
      final day = date % 100;
      if (day > 0) {
        continue;
      }

      final yearNode = yearNodes.putIfAbsent(year, () {
        final count = _countByDate[year * 10000] ?? 0;
        final node = TreeNode<FeedNode>(
            key: '$year', data: FeedNode(count: count, date: DateTime(year)));
        tree.add(node);
        return node;
      });

      if (month > 0) {
        final count = _countByDate[year * 10000 + month * 100] ?? 0;
        final node = TreeNode(
            key: '$year-$month',
            data: FeedNode(count: count, date: DateTime(year, month)));
        yearNode.add(node);
      }
    }

    _rootTree = tree;

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

  Future signout() async {
    if (_currentActor == null) {
      return;
    }

    try {
      await atproto.deleteSession(
        service: _currentActor!.service,
        refreshJwt: _currentActor!.session!.refreshJwt,
      );
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
      final newSession =
          await atproto.refreshSession(refreshJwt: actor.session!.refreshJwt);

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

    return bluesky.Bluesky.fromSession(actor.session!);
  }

  Future syncFeed() async {
    if (_currentActor == null) {
      return;
    }
    _lastSync = DateTime.now();

    // sync old posts
    var cursor = _tailCursors[_currentActor!.did];
    do {
      cursor = await getFeed(cursor: cursor);
      _tailCursors[_currentActor!.did] = cursor;

      if (kDebugMode) {
        print('getFeed $cursor');
      }

      updateSharedPrefrences();
      countDatePosts();
      notifyListeners();
    } while (cursor != null && cursor.isNotEmpty);

    if (kDebugMode) {
      print('syncFeed done');
    }
  }

  Future clearFeed() async {
    await database.delete(database.posts).go();
    _rootTree.clear();

    _lastSync = null;
    _tailCursors.clear();

    updateSharedPrefrences();
    countDatePosts();
    notifyListeners();
  }

  Future<String?> getFeed({String? cursor}) async {
    try {
      final bsky = await getBluesky(_currentActor!);

      final response = await bsky.feed.getAuthorFeed(
        actor: _currentActor!.did,
        limit: 100,
        cursor: cursor ?? '',
      );

      final status = response.status;

      if (status.code != 200) {
        throw Exception(status.message);
      }

      if (kDebugMode) {
        print('code:${status.code} message:${status.message}');
        print(response.request.toString());
        //print(response.data);
      }

      final feedData = response.data;
      cursor = feedData.cursor;

      if (kDebugMode) {
        print('feeds:${feedData.feed.length} cursor:$cursor');
      }

      final itemCount = database.posts.id.count();
      final query = database.posts.selectOnly()..addColumns([itemCount]);
      final before = await query.map((row) => row.read(itemCount)).getSingle();

      for (var feedView in feedData.feed) {
        final feedAuthorDid = getFeedAuthorDid(feedView);
        final post = feedView.post;
        final repost = feedView.post.viewer.repost;

        // if repost of own post
        if (repost != null && post.author.did == feedAuthorDid) {
          await database.into(database.posts).insert(
                PostsCompanion.insert(
                  uri: post.uri.toString(),
                  feedAuthorDid: Value(feedAuthorDid),
                  authorDid: feedAuthorDid,
                  indexed: post.indexedAt,
                  replyDid: getFeedReplyDid(feedView), // who's reply
                  havEmbedImages: post.embed is bluesky.UEmbedViewImages,
                  havEmbedExternal: post.embed is bluesky.UEmbedViewExternal,
                  havEmbedRecord: post.embed is bluesky.UEmbedViewRecord,
                  havEmbedRecordWithMedia:
                      post.embed is bluesky.UEmbedViewRecordWithMedia,
                  havEmbedVideo: post.embed is bluesky.UEmbedViewVideo,
                  reasonRepost: false,
                  post: jsonEncode(feedView.toJson()),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        await database.into(database.posts).insert(
              PostsCompanion.insert(
                uri: repost != null
                    ? repost.toString()
                    : post.uri.toString(), // repost or
                feedAuthorDid: Value(feedAuthorDid), // repost or
                authorDid: post.author.did,
                indexed: getFeedIndexed(feedView), // repost or
                replyDid: getFeedReplyDid(feedView), // who's reply
                havEmbedImages: post.embed is bluesky.UEmbedViewImages,
                havEmbedExternal: post.embed is bluesky.UEmbedViewExternal,
                havEmbedRecord: post.embed is bluesky.UEmbedViewRecord,
                havEmbedRecordWithMedia:
                    post.embed is bluesky.UEmbedViewRecordWithMedia,
                havEmbedVideo: post.embed is bluesky.UEmbedViewVideo,
                reasonRepost: repost != null,
                post: jsonEncode(feedView.toJson()),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final after = await query.map((row) => row.read(itemCount)).getSingle();
      if (before == after) {
        cursor = null;
        if (kDebugMode) {
          print('No new record. before:$before after:$after');
        }
      }
    } on xrpc.XRPCException catch (e) {
      final status = e.response.status;

      if (kDebugMode) {
        print('${status.code} ${status.message}');
        print(e.response.request.toString());
        print(e.response.data.toJson());
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }

    return cursor;
  }

  static String getFeedAuthorDid(bluesky.FeedView feedView) {
    final reason = feedView.reason;
    if (reason != null && reason is bluesky.UReasonRepost) {
      return reason.data.by.did;
    }
    return feedView.post.author.did;
  }

  static DateTime getFeedIndexed(bluesky.FeedView feedView) {
    final reason = feedView.reason;
    if (reason != null && reason is bluesky.UReasonRepost) {
      return reason.data.indexedAt;
    }
    return feedView.post.indexedAt;
  }

  static String getFeedReplyDid(bluesky.FeedView feedView) {
    final reply = feedView.reply;
    if (reply != null && reply.parent is bluesky.UReplyPostRecord) {
      return (reply.parent as bluesky.UReplyPostRecord).data.author.did;
    }
    return '';
  }

  // { "feed": [ feed.posts ] }
  Future exportFeed(File file) async {
    try {
      final posts = await (database.select(database.posts)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
            ]))
          .get();
      final data = posts.map((row) => jsonDecode(row.post)).toList();
      final json = jsonEncode({'feed': data});
      await file.writeAsString(json);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<bluesky.PostThread> getPostThread(bluesky_core.AtUri uri) async {
    try {
      final bsky = await getBluesky(currentActor!);
      final response = await bsky.feed.getPostThread(uri: uri);
      return response.data;
    } on xrpc.XRPCException catch (e) {
      final status = e.response.status;

      if (kDebugMode) {
        print('${status.code} ${status.message}');
        print(e.response.request.toString());
        print(e.response.data.toJson());
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }
}
