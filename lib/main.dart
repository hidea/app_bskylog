import 'dart:convert';
import 'dart:io';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:bskylog/rotation_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

import 'database.dart';
import 'define.dart';
import 'feed_card.dart';
import 'model.dart';
import 'search_field.dart';
import 'signin_screen.dart';
import 'utils.dart';

class _Destination {
  final Widget icon;
  final Widget label;
  final bool disabled;

  _Destination({
    required this.icon,
    required this.label,
    required this.disabled,
  });
}

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

final GlobalKey<ScaffoldMessengerState> scaffoldMsgKey =
    GlobalKey<ScaffoldMessengerState>();

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

_menuRevealInFolder(BuildContext context) async {
  final docFolder = await getApplicationDocumentsDirectory();
  launchUrlString('file://${docFolder.path}');
}

_menuExportToJson(BuildContext context) async {
  try {
    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an feed.bsky.app.getAuthorFeed json file:',
      fileName: 'auther-feed.json',
    );
    if (outputFile == null) {
      return null;
    }
    final file = File(outputFile);
    await context.read<Model>().exportFeed(file);

    scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
        content: Text("Export done."),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'open folder',
          onPressed: () => launchUrlString('file://${file.parent.path}'),
        ),
        showCloseIcon: true,
        duration: const Duration(days: 365)));
  } catch (e) {
    scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
        content: Text("Export failed.\n$e"),
        showCloseIcon: true,
        duration: const Duration(days: 365)));
  }
}

List<PlatformMenuItem> _menu(BuildContext context) {
  return <PlatformMenu>[
    PlatformMenu(
      label: 'bskylog MenuBar',
      menus: [
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.about))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.about),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
                label: 'Settings…',
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.comma, meta: true),
                onSelected: null),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.servicesSubmenu))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.hide))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.hideOtherApplications))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.showAllApplications))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications),
          ],
        ),
        PlatformMenuItemGroup(members: [
          if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit))
            const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit),
        ]),
      ],
    ),
    PlatformMenu(
      label: 'Log',
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
                label: 'Reveal in Folder',
                onSelected: () => _menuRevealInFolder(context)),
            PlatformMenuItem(
                label: 'Export to json...',
                onSelected: () => _menuExportToJson(context)),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: 'View',
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
                label: 'Toggled Filter Menu',
                onSelected: () =>
                    context.read<Model>().toggleVisibleFilterMenu()),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.toggleFullScreen))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.toggleFullScreen),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: 'Window',
      menus: [
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.minimizeWindow))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.minimizeWindow),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.zoomWindow))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.zoomWindow),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.arrangeWindowsInFront))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.arrangeWindowsInFront),
          ],
        ),
      ],
    ),
  ];
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
    final router = MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      scaffoldMessengerKey: scaffoldMsgKey,
      routerConfig: _router,
    );

    if (Platform.isMacOS) {
      return PlatformMenuBar(
        menus: _menu(context),
        child: router,
      );
    }

    return router;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _feedController = ScrollController();
  final _autoScrollController = AutoScrollController();
  bool isSyncing = false;
  bool visibleTopButton = false;

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
  void initState() {
    super.initState();

    _feedController.addListener(() {
      if (_feedController.hasClients) {
        if (_feedController.offset > 0) {
          if (!visibleTopButton) {
            setState(() {
              visibleTopButton = true;
            });
          }
        } else {
          if (visibleTopButton) {
            setState(() {
              visibleTopButton = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _scaffoldDesktop() : _scaffoldMobile();
  }

  Widget _scaffoldDesktop() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          _buildNavigationRail(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildFeed(),
          ),
          Visibility(
            visible: context.watch<Model>().visibleFilterMenu,
            child: _buildSearchPanel(),
          ),
        ],
      ),
    );
  }

  Widget _scaffoldMobile() {
    final actor = context.watch<Model>().currentActor;
    final profile = actor?.profile;
    final avator = profile != null && profile.avatar != null
        ? CachedNetworkImageProvider(profile.avatar!)
        : null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(radius: 16, backgroundImage: avator),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text(Define.title),
        //toolbarHeight: 36,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.manage_search),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      endDrawer: _buildEndDrawer(),
      body: _buildFeed(),
    );
  }

  List<_Destination> get destinations => [
        _Destination(
          icon: RotationIcon(icon: Icons.sync, syncing: isSyncing),
          label: const Text('Log Sync'),
          disabled: isSyncing || context.watch<Model>().currentActor == null,
        ),
        _Destination(
          icon: const Icon(Icons.delete_forever),
          label: const Text('Log Clear'),
          disabled: isSyncing || context.watch<Model>().currentActor == null,
        ),
        _Destination(
          icon: const Icon(Icons.login),
          label: const Text('Sign In'),
          disabled: isSyncing || context.watch<Model>().currentActor != null,
        ),
        _Destination(
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          disabled: isSyncing || context.watch<Model>().currentActor == null,
        ),
      ];

  Widget _buildDrawer() {
    final actor = context.watch<Model>().currentActor;
    final profile = actor?.profile;
    final avator = profile != null && profile.avatar != null
        ? CachedNetworkImageProvider(profile.avatar!)
        : null;

    return NavigationDrawer(
      selectedIndex: -1,
      onDestinationSelected: _handleDrawerSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(radius: 20, backgroundImage: avator),
          ),
        ),
        ...destinations.map(
          (_Destination destination) {
            return NavigationDrawerDestination(
              label: destination.label,
              icon: destination.icon,
              enabled: !destination.disabled,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: Divider(),
        ),
        NavigationDrawerDestination(
          label: const Text('Sound'),
          icon: context.watch<Model>().volume == 0
              ? const Icon(Icons.volume_off)
              : const Icon(Icons.volume_up),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${context.read<Model>().packageInfo!.version}'
                '+${context.read<Model>().packageInfo!.buildNumber}'),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;

    final actor = context.watch<Model>().currentActor;
    final profile = actor?.profile;
    final avator = profile != null && profile.avatar != null
        ? CachedNetworkImageProvider(profile.avatar!)
        : null;

    return NavigationRail(
      minWidth: 52,
      selectedIndex: null,
      labelType:
          isTablet ? NavigationRailLabelType.all : NavigationRailLabelType.none,
      leading: CircleAvatar(radius: 20, backgroundImage: avator),
      destinations: [
        ...destinations.map(
          (_Destination destination) {
            return NavigationRailDestination(
              label: destination.label,
              icon: destination.icon,
              disabled: destination.disabled,
            );
          },
        ),
      ],
      trailing: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () => context.read<Model>().toggleVolume(),
                    icon: context.watch<Model>().volume == 0
                        ? const Icon(Icons.volume_off)
                        : const Icon(Icons.volume_up),
                  ),
                  Text('Sound',
                      style: Theme.of(context)
                          .navigationRailTheme
                          .selectedLabelTextStyle),
                ],
              ),
              Column(
                children: [
                  PopupMenuButton<int>(
                    tooltip: '',
                    popUpAnimationStyle: AnimationStyle.noAnimation,
                    icon: const Icon(Icons.storage),
                    onSelected: (int item) async {
                      switch (item) {
                        case 0:
                          _menuRevealInFolder(context);
                          break;
                        case 1:
                          _menuExportToJson(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Reveal in Folder'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Export to json...'),
                      ),
                    ],
                  ),
                  Text('Log',
                      style: Theme.of(context)
                          .navigationRailTheme
                          .selectedLabelTextStyle),
                ],
              ),
              const SizedBox(height: 16),
              Text('${context.read<Model>().packageInfo!.version}'
                  '+${context.read<Model>().packageInfo!.buildNumber}'),
            ],
          ),
        ),
      ),
      onDestinationSelected: _handleDrawerSelected,
    );
  }

  void _handleDrawerSelected(int index) {
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
              content: Text("Sign out"), behavior: SnackBarBehavior.floating));
        });
        break;
    }
  }

  Widget _buildFeed() {
    return Column(
      children: [
        SearchField(
          visible: context.watch<Model>().visibleFilterMenu,
          onVisible: (_) => context.read<Model>().toggleVisibleFilterMenu(),
        ),
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                controller: _feedController,
                slivers: [
                  StreamBuilder(
                    stream: context.watch<Model>().filterSearch().watch(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()));
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
                    child:
                        SizedBox(height: MediaQuery.paddingOf(context).bottom),
                  ),
                ],
              ),
              if (visibleTopButton)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: IconButton.outlined(
                          onPressed: () => _feedController
                              .jumpTo(_feedController.position.minScrollExtent),
                          icon: Icon(Icons.keyboard_arrow_up))),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchPanel() {
    return SizedBox(
      width: 200.0,
      height: MediaQuery.of(context).size.height,
      child: CustomScrollView(
        controller: _autoScrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('Sort', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildSort(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('Visible', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildVisible(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildCalendar(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('Archives', style: TextStyle(fontWeight: FontWeight.bold)),
                //_buildHandles(),
                //_buildHashTags(),
              ],
            ),
          ),
          _buildTree(),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }

  Widget _buildEndDrawer() {
    return NavigationDrawer(
      children: [_buildSearchPanel()],
    );
  }

  Widget _buildSort() {
    return LayoutBuilder(builder: (context, constraints) {
      return ToggleButtons(
        constraints: BoxConstraints.expand(
            width: (constraints.maxWidth - 16) / 2, height: 30),
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
    });
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
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    );
  }
}
