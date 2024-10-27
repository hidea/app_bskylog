import 'dart:convert';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

import 'database.dart';
import 'define.dart';
import 'feed_card.dart';
import 'model.dart';
import 'search_field.dart';
import 'signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  @override
  void initState() {
    super.initState();
  }

  void _syncFeed() async {
    context.read<Model>().syncFeed();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final safePadding = MediaQuery.of(context).padding;

    final database = context.read<Model>().database;

    return Scaffold(
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
            trailing: const Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('test'),
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
                  database.delete(database.posts).go();
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
                        stream: context.watch<Model>().filter().watch(),
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
                                final feed = bluesky.FeedView.fromJson(
                                    jsonDecode(posts[index].post));
                                return Card(child: FeedCard(feed));
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
          if (context.watch<Model>().roorTree != null)
            SizedBox(
              width: 200,
              child: TreeView.simple(
                showRootNode: false,
                tree: context.watch<Model>().roorTree!,
                builder: (context, node) {
                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4.0),
                    title: Text(node.key),
                    onTap: () {
                      if (node.level > 0) {
                        if (node.data is DateTime) {
                          final date = node.data as DateTime;
                          context.read<Model>().setSearchYear(date.year);
                          if (node.level > 1) {
                            context.read<Model>().setSearchMonth(date.month);
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

final sampleTree = TreeNode.root()
  ..addAll([
    TreeNode(key: "Archives")
      ..addAll([
        TreeNode(key: "2024", data: DateTime(2024))
          ..addAll([
            TreeNode(key: "10", data: DateTime(2024, 10)),
            TreeNode(key: "09", data: DateTime(2024, 9)),
            TreeNode(key: "08", data: DateTime(2024, 8)),
            TreeNode(key: "07", data: DateTime(2024, 7)),
            TreeNode(key: "06", data: DateTime(2024, 6)),
            TreeNode(key: "05", data: DateTime(2024, 5)),
            TreeNode(key: "04", data: DateTime(2024, 4)),
            TreeNode(key: "03", data: DateTime(2024, 3)),
            TreeNode(key: "02", data: DateTime(2024, 2)),
            TreeNode(key: "01", data: DateTime(2024, 1)),
          ]),
        TreeNode(key: "2023", data: DateTime(2023))
          ..addAll([
            TreeNode(key: "12", data: DateTime(2023, 12)),
            TreeNode(key: "11", data: DateTime(2023, 11)),
            TreeNode(key: "10", data: DateTime(2023, 10)),
            TreeNode(key: "09", data: DateTime(2023, 9)),
            TreeNode(key: "08", data: DateTime(2023, 8)),
            TreeNode(key: "07", data: DateTime(2023, 7)),
            TreeNode(key: "06", data: DateTime(2023, 6)),
            TreeNode(key: "05", data: DateTime(2023, 5)),
            TreeNode(key: "04", data: DateTime(2023, 4)),
            TreeNode(key: "03", data: DateTime(2023, 3)),
            TreeNode(key: "02", data: DateTime(2023, 2)),
            TreeNode(key: "01", data: DateTime(2023, 1)),
          ]),
      ]),
  ]);
