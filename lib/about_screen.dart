import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          childAspectRatio: 1.5,
          crossAxisCount: 3,
          children: [
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: Text(
                'About bskylog',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: Text(
                  'bskylog is logging your Bluesky posts, likes, reposts and quote. And you can filtering them.'),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                leading: Icon(Icons.person),
                title: Text('Author'),
                subtitle: Text('hidea'),
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                title: Text('Version'),
                subtitle: Text('${context.read<Model>().packageInfo!.version}'
                    '+${context.read<Model>().packageInfo!.buildNumber}'),
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: Text(
                'My other apps.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.green, brightness: Brightness.light)
                  .surfaceContainer,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                leading: Icon(Icons.person),
                title: Text('SkyThrow'),
                subtitle: Text('Bluesky posting only client.'),
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.white, brightness: Brightness.light)
                  .surface,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                leading: Icon(Icons.map),
                title: Text('ShiKuChoSon'),
                subtitle: Text(
                    'Daily game to guess Japans municipalities with six attempts, using distance, direction, and prefecture hints.'),
              ),
            ),
            Card(
              color: ColorScheme.fromSeed(
                      seedColor: Colors.red, brightness: Brightness.light)
                  .surfaceBright,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                leading: Icon(Icons.menu_book),
                title: Text('sinkan.net'),
                subtitle: Text(
                    'Service that provides information on newly released books, allowing users to discover and explore upcoming titles across various genres.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
