import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

import 'database.dart';
import 'define.dart';
import 'feed_card.dart';
import 'model.dart';
import 'search_field.dart';
import 'signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _syncFeed() async {
    context.read<Model>().syncFeed();
  }

  @override
  Widget build(BuildContext context) {
    final database = context.read<Model>().database;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 120.0,
                    child: DrawerHeader(child: Text(Define.title)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      context.pop();
                      // context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.disabled_by_default),
                    title: const Text('Log clear'),
                    onTap: () {
                      database.delete(database.posts).go();
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                  'version ${context.read<Model>().packageInfo!.buildNumber} +${context.read<Model>().packageInfo!.version}'),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text(Define.title),
        actions: <Widget>[
          if (context.watch<Model>().currentActor == null)
            IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => context.push('/signin')),
          if (context.watch<Model>().currentActor != null)
            IconButton(
                icon: const Icon(Icons.sync), onPressed: () => _syncFeed()),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: SearchField()),
          StreamBuilder(
            stream: context.watch<Model>().filter().watch(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                    child: CircularProgressIndicator());
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
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
