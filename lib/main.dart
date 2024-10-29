import 'dart:convert';
import 'dart:io';

import 'package:animated_tree_view/animated_tree_view.dart';
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
  void _syncFeed() async {
    context.read<Model>().syncFeed();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final safePadding = MediaQuery.of(context).padding;

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
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.sync),
                label: const Text('Log Sync'),
                padding: EdgeInsets.only(top: safePadding.top),
                disabled: context.watch<Model>().currentActor == null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Log Clear'),
                disabled: context.watch<Model>().currentActor == null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                disabled: context.watch<Model>().currentActor != null,
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                disabled: context.watch<Model>().currentActor == null,
              ),
            ],
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                      context.read<Model>().clearFeed();
                    },
                  );
                  break;
                case 2:
                  context.push('/signin');
                  break;
                case 3:
                  context.read<Model>().signout();
                  break;
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                const SearchField(),
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
          SizedBox(
            width: 200,
            child: Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 8),
                _buildTree(),
                //_buildHandles(),
                //_buildHashTags(),
              ],
            ),
          ),
        ],
      ),
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
            child: Text(
              text,
              style: const TextStyle(fontSize: 9),
            ),
          );
        },
        headerTitleBuilder: (context, day) {
          final text = DateFormat('y.M').format(day);
          return Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
      focusedDay: context.watch<Model>().focusedDay,
      firstDay: context.watch<Model>().firstDay,
      lastDay: context.watch<Model>().lastDay,
      onDaySelected: (selectedDay, focusedDay) {
        context.read<Model>().setSearchYear(selectedDay.year);
        context.read<Model>().setSearchMonth(selectedDay.month);
        context.read<Model>().setSearchDay(selectedDay.day);
      },
    );
  }

  Widget _buildTree() {
    if (context.watch<Model>().roorTree == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: double.infinity,
            child: TreeView.simple(
              showRootNode: false,
              expansionBehavior: ExpansionBehavior.collapseOthers,
              tree: context.watch<Model>().roorTree!,
              onTreeReady: (controller) {
                final archivesNode = context.read<Model>().archivesNode;
                if (archivesNode != null) {
                  controller.expandNode(archivesNode);
                }
              },
              builder: (context, node) {
                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4.0),
                  title: Text(node.key),
                  onTap: () {
                    if (node.level > 1) {
                      if (node.data is DateTime) {
                        final date = node.data as DateTime;
                        context.read<Model>().setSearchYear(date.year);
                        if (node.level > 2) {
                          context.read<Model>().setSearchMonth(date.month);
                        }
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
