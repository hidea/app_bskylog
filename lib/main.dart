import 'dart:convert';
import 'dart:io';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:bskylog/rotation_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:window_manager/window_manager.dart';

import 'database.dart';
import 'define.dart';
import 'feed_card.dart';
import 'model.dart';
import 'search_field.dart';
import 'signin_screen.dart';
import 'utils.dart';

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(800, 600),
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: Define.title,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final database = AppDatabase();

  final model = Model(database: database);
  await model.syncDataWithProvider();

  runApp(ChangeNotifierProvider(create: (_) => model, child: const MyApp()));
}

final GlobalKey<ScaffoldMessengerState> scaffoldMsgKey =
    GlobalKey<ScaffoldMessengerState>();

final _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'root',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/signin',
      name: 'signin',
      builder: (context, state) {
        final extra =
            state.extra != null ? state.extra as Map<String, String> : {};
        return SigninScreen(
          service: extra['service'] ?? Define.serviceBskySocial,
          identifier: extra['identifier'] ?? '',
          password: '',
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      scaffoldMessengerKey: scaffoldMsgKey,
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _autoScrollController = AutoScrollController();
  bool isSyncing = false;
  bool visibleSearch = true;

  void _syncFeed() {
    setState(() {
      isSyncing = true;
    });
    context.read<Model>().syncFeed().then((_) {
      scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
          content: Text("Sync done"), behavior: SnackBarBehavior.floating));

      setState(() {
        isSyncing = false;
      });
    }).catchError((e) {
      scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
          content: Text("Sync error: $e"),
          behavior: SnackBarBehavior.floating));

      setState(() {
        isSyncing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final safePadding = MediaQuery.of(context).padding;

    final actor = context.watch<Model>().currentActor;
    final profile = actor?.profile;
    final avator = profile != null && profile.avatar != null
        ? NetworkImage(profile.avatar!)
        : null;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text(Define.title),
              toolbarHeight: 36,
            ),
      body: Row(
        children: [
          NavigationRail(
            minWidth: 52,
            selectedIndex: null,
            labelType: isTablet
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.none,
            leading: SizedBox(
              height: 50,
              child: CircleAvatar(radius: 20, backgroundImage: avator),
            ),
            destinations: [
              NavigationRailDestination(
                icon: RotationIcon(
                  icon: Icons.sync,
                  syncing: isSyncing,
                ),
                label: const Text('Log Sync'),
                padding: EdgeInsets.only(top: safePadding.top),
                disabled:
                    isSyncing || context.watch<Model>().currentActor == null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Log Clear'),
                disabled:
                    isSyncing || context.watch<Model>().currentActor == null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                disabled:
                    isSyncing || context.watch<Model>().currentActor != null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                disabled:
                    isSyncing || context.watch<Model>().currentActor == null,
              ),
            ],
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.storage),
                    const SizedBox(height: 8),
                    Text('${context.read<Model>().packageInfo!.version}'
                        '+${context.read<Model>().packageInfo!.buildNumber}'),
                  ],
                ),
              ),
            ),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  _syncFeed();
                  break;
                case 1:
                  showConfirmDialog(
                    context: context,
                    ok: const Text('Delete'),
                    content: const Text('Are you sure trancate all log ?'),
                    onOk: () {
                      context.read<Model>().clearFeed().then((_) {
                        scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
                            content: Text("Trancate all log"),
                            behavior: SnackBarBehavior.floating));
                      });
                    },
                  );
                  break;
                case 2:
                  context.push('/signin');
                  break;
                case 3:
                  context.read<Model>().signout().then((_) {
                    scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
                        content: Text("Sign out"),
                        behavior: SnackBarBehavior.floating));
                  });
                  break;
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                SearchField(
                    visible: visibleSearch,
                    onVisible: (visible) {
                      setState(() {
                        visibleSearch = visible;
                      });
                    }),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      StreamBuilder(
                        stream: context.watch<Model>().filterSearch().watch(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SliverToBoxAdapter(
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }
                          final posts = snapshot.data!;
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final feed = posts[index];
                                final feedView = bluesky.FeedView.fromJson(
                                    jsonDecode(feed.post));
                                return Card(child: FeedCard(feed, feedView));
                              },
                              childCount: posts.length,
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                            height: MediaQuery.paddingOf(context).bottom),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: visibleSearch,
            child: SizedBox(
              width: 200.0,
              child: CustomScrollView(
                controller: _autoScrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text('Sort',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildSort(),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text('Visible',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildVisible(),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text('Calendar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildCalendar(),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text('Archives',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        //_buildHandles(),
                        //_buildHashTags(),
                      ],
                    ),
                  ),
                  _buildTree(),
                  SliverToBoxAdapter(
                    child:
                        SizedBox(height: MediaQuery.paddingOf(context).bottom),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSort() {
    return ToggleButtons(
      constraints: BoxConstraints.expand(width: 92, height: 30),
      borderRadius: BorderRadius.circular(20),
      isSelected: [
        context.watch<Model>().sortOrder == SortOrder.desc,
        context.watch<Model>().sortOrder == SortOrder.asc
      ],
      onPressed: (int index) {
        context
            .read<Model>()
            .setSortOrder(index == 0 ? SortOrder.desc : SortOrder.asc);
      },
      children: const [Text('Latest'), Text('Oldest')],
    );
  }

  Widget _buildVisible() {
    return Column(
      children: [
        for (final type in VisibleType.values)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: _buildToggleButton(
              label: type.name,
              mode: context.watch<Model>().visible(type),
              onChanged: (mode) {
                context.read<Model>().setVisible(type, mode);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required VisibleMode mode,
    required Function(VisibleMode) onChanged,
  }) {
    final color = mode == VisibleMode.disable ? Colors.grey : null;
    final selectedColor = mode == VisibleMode.disable
        ? Colors.grey
        : mode == VisibleMode.show
            ? Colors.green
            : mode == VisibleMode.hide
                ? Colors.red
                : Colors.blue;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ToggleButtons(
          constraints: BoxConstraints.expand(
              width: (constraints.maxWidth - 16) / 2, height: 30),
          borderRadius: BorderRadius.circular(20),
          isSelected: [
            mode != VisibleMode.only && mode != VisibleMode.disable,
            mode == VisibleMode.only
          ],
          color: color,
          borderColor: color?.shade300,
          selectedColor: selectedColor,
          selectedBorderColor: selectedColor.shade300,
          fillColor: selectedColor.shade100,
          onPressed: (int index) {
            if (index == 0) {
              onChanged(mode == VisibleMode.show
                  ? VisibleMode.hide
                  : VisibleMode.show);
            } else {
              onChanged(VisibleMode.only);
            }
          },
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mode == VisibleMode.show) Icon(Icons.check, size: 14),
                if (mode == VisibleMode.hide) Icon(Icons.close, size: 14),
                if (mode == VisibleMode.show || mode == VisibleMode.hide)
                  SizedBox(width: 4),
                Text(label),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text('only'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      rowHeight: 30,
      pageJumpingEnabled: true,
      weekendDays: const [DateTime.saturday],
      holidayPredicate: (day) => day.weekday == DateTime.sunday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(
        headerPadding: EdgeInsets.zero,
      ),
      calendarStyle: const CalendarStyle(
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
        weekendTextStyle: TextStyle(color: Colors.blue),
        holidayTextStyle: TextStyle(color: Colors.red),
        holidayDecoration: BoxDecoration(),
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day);
          return Center(
            child: Text(text, style: const TextStyle(fontSize: 9)),
          );
        },
        headerTitleBuilder: (context, day) {
          final text = DateFormat('y.M').format(day);
          return Center(
            child: TextButton(
              style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero)),
              onPressed: () {
                context.read<Model>().setSearchMonth(day.year, day.month);
              },
              child: Text(text, style: const TextStyle(fontSize: 18)),
            ),
          );
        },
      ),
      focusedDay: context.watch<Model>().focusedDay,
      firstDay: context.watch<Model>().firstDay,
      lastDay: context.watch<Model>().lastDay,
      onDaySelected: (selectedDay, focusedDay) {
        context
            .read<Model>()
            .setSearchDay(selectedDay.year, selectedDay.month, selectedDay.day);
      },
    );
  }

  Widget _buildTree() {
    return SliverTreeView.simple(
      scrollController: _autoScrollController,
      showRootNode: false,
      expansionBehavior: ExpansionBehavior.collapseOthers,
      tree: context.watch<Model>().rootTree,
      builder: (context, node) {
        final data = node.data as FeedNode;
        String title = '';
        String tooltip = '';
        if (node.level > 0) {
          title = '${data.date.year} (${data.count})';
          tooltip = 'Search this year';
          if (node.level > 1) {
            title = '${data.date.month} (${data.count})';
            tooltip = 'Search this month';
          }
        }

        return ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -4.0),
          title: Tooltip(
              message: tooltip,
              waitDuration: Duration(milliseconds: 500),
              child: Text(title)),
          onTap: () {
            if (node.level > 0) {
              if (node.level > 1) {
                context
                    .read<Model>()
                    .setSearchMonth(data.date.year, data.date.month);
              } else {
                context.read<Model>().setSearchYear(data.date.year);
              }
            }
          },
        );
      },
      //),
    );
  }
}
