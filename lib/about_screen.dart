import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'main.dart';
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
          childAspectRatio: isDesktop ? 1.5 : 2.5,
          crossAxisCount: isDesktop ? 3 : 1,
          children: [
            _buildCard(context, title: 'About bskylog'),
            _buildCard(context,
                icon: Icons.description,
                description:
                    'bskylog logs locally your Bluesky posts, reposts and quote. And you can filtering them.'),
            _buildCard(context,
                icon: Icons.person,
                title: 'Author',
                description: 'hidea',
                link: 'https://bsky.app/profile/hidea.bsky.social'),
            _buildCard(context,
                icon: Symbols.graph_1,
                title: 'Version',
                description: context.watch<Model>().versionPlusBuildNumber +
                    (context.watch<Model>().newRelease
                        ? '\n(New release available)'
                        : ''),
                link: 'https://github.com/hidea/app_bskylog/releases'),
            _buildCard(context,
                color: Colors.purple, title: 'My other product.'),
            _buildCard(
              context,
              color: Colors.blue,
              icon: Icons.alternate_email,
              title: 'SkyThrow',
              description:
                  'Client that specializes posting to Bluesky. Multi account and #hashtag support makes posting more functional.',
              link: 'https://skythrow.com/',
            ),
            _buildCard(
              context,
              color: Colors.green,
              icon: Icons.menu_book,
              title: 'sinkan.net',
              description:
                  'Service that provides information on newly released books, allowing users to discover and explore upcoming titles across various genres.',
              link: 'https://sinkan.net/',
            ),
            _buildCard(
              context,
              color: Colors.orange,
              icon: Icons.map,
              title: 'ShiKuChoSon',
              description:
                  'Daily game to guess Japans municipalities with six attempts, using distance, direction, and prefecture hints.',
              link: 'https://shikuchoson.jp/',
            ),
            _buildCard(
              context,
              color: Colors.red,
              icon: Icons.sports_baseball,
              title: 'NPB savings graph',
              description: 'Nippon Professional Baseball savings line graph.',
              link: 'https://chok.in/',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {Color color = Colors.grey,
      IconData? icon,
      String? title,
      String? description,
      String? link}) {
    return Card.outlined(
      color:
          ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light)
              .surfaceBright,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: color,
        ),
      ),
      child: InkWell(
        onTap: link != null
            ? () {
                launchUrlString(link);
              }
            : null,
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          leading: icon != null ? Icon(icon) : null,
          title: title != null
              ? Text(
                  title,
                  style: description == null
                      ? Theme.of(context).textTheme.headlineMedium
                      : null,
                )
              : null,
          subtitle: description != null ? Text(description) : null,
        ),
      ),
    );
  }
}
