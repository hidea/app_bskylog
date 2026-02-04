import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:bluesky/app_bsky_feed_defs.dart' as bsky_feed;
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:bskylog/embed_external.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'avatar_icon.dart';
import 'database.dart';
import 'define.dart';
import 'embed_record.dart';
import 'embed_images.dart';
import 'embed_record_with_media.dart';
import 'embed_video.dart';
import 'model.dart';
import 'post_record.dart';
import 'utils.dart';

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

const elapseHalf = 0.5;
const elapseMin = 30;
const elapseMax = 60 * 24 * 30;

class FeedCard extends StatefulWidget {
  const FeedCard(this.feed, this.feedView, {super.key});

  final Post feed;
  final bsky_feed.FeedViewPost feedView;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  //late Future<bluesky.Posts> _future;

  @override
  void initState() {
    super.initState();

    final model = context.read<Model>();
    final currentActorDid = model.currentActor?.did;
    final feed = widget.feed;
    final post = widget.feedView.post;

    // reget post
    // need currentActor is feed author
    if (currentActorDid == feed.feedAuthorDid) {
      // if post author is not feed author (it's repost)
      //  -> possibility deleted
      // if hav embed.record, embed.recordWithMedia
      //  -> possibility deleted, blocked
      if (feed.reasonRepost ||
          (feed.havEmbedRecord || feed.havEmbedRecordWithMedia)) {
        // time elapsed since post indexed, last retrieval
        final indexedElapse =
            DateTime.now().difference(feed.indexed.toLocal()).inMinutes;
        final retrievedElapse =
            DateTime.now().difference(feed.retrieved).inMinutes;

        if (retrievedElapse * elapseHalf >
            math.max(math.min(indexedElapse, elapseMax), elapseMin)) {
          context.read<Model>().getUriPosts([post.uri]).then((posts) {
            if (feed.reasonRepost) {
              // (repost) post deleted, post column to empty
              // otherwize, update retrieved only
              if (posts.posts.isEmpty) {
                model.updateFeedOnlyPosts(feed.uri, '{}');
              } else {
                model.updateFeedRetrieved(feed.uri);
              }
            } else if (feed.havEmbedRecord || feed.havEmbedRecordWithMedia) {
              // feedAuthorDid's post deleted, embed replace to notFound
              // otherwize, replace all
              if (posts.posts.isEmpty) {
                final recordNotFound = {
                  "\$type": "app.bsky.embed.record#viewNotFound",
                  "uri": post.uri.toString(),
                  "notFound": true,
                };
                if (feed.havEmbedRecord) {
                  // replase embed to recordNotFound
                  final feedView = widget.feedView.toJson();
                  feedView['post']['embed'] = {
                    "\$type": "app.bsky.embed.record#view",
                    "record": recordNotFound
                  };
                  model.updateFeedOnlyPosts(feed.uri, jsonEncode(feedView));
                } else if (feed.havEmbedRecordWithMedia) {
                  // replase embed.record.record to recordNotFound
                  final feedView = widget.feedView.toJson();
                  feedView['post']['embed']['record']['record'] =
                      recordNotFound;
                  model.updateFeedOnlyPosts(feed.uri, jsonEncode(feedView));
                }
              } else {
                // replase embed to new post
                if (kDebugMode) {
                  final original = jsonEncode(post.toJson());
                  final current = jsonEncode(posts.posts[0].toJson());
                  final d = diff(original, current);
                  print('[EUP]replase embed post: $d');
                }
                model.updateFeedOnlyPosts(
                    feed.uri, jsonEncode({"post": posts.posts[0]}));
              }
            }
          }).catchError((e) {
            if (kDebugMode) {
              print('reget post error: $e');
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;
    final post = widget.feedView.post;
    final author = post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;

    final embedWidth =
        isDesktop ? 424.0 : MediaQuery.of(context).size.width - 80.0;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feed.reasonRepost) _buildRepost(),
          if (widget.feedView.reply != null &&
              widget.feedView.reply!.parent.isPostView)
            _buildReply(widget.feedView),
          SelectionArea(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
              titleAlignment: ListTileTitleAlignment.top,
              leading: AvatarIcon(avatar: author.avatar, size: 20),
              title: Text.rich(
                TextSpan(
                    text: displayName,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        color: Colors.black),
                    children: [
                      WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text: '@${author.handle}',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .fontSize,
                            color: Colors.black54),
                      ),
                    ]),
              ),
              subtitle: PostRecordWidget(
                  record: FeedPostRecord.fromJson(post.record),
                  onMention: _tapMention,
                  onLink: _tapLink,
                  onTag: _tapTag),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 64),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.embed != null)
                    post.embed!.when(
                        embedRecordView: (record) => EmbedRecordWidget(
                              widget.feed,
                              record,
                              width: embedWidth,
                              height: embedWidth,
                            ),
                        embedImagesView: (images) => EmbedImagesWidget(
                              widget.feed,
                              images,
                              width: embedWidth,
                            ),
                        embedExternalView: (external) => EmbedExternalWidget(
                              widget.feed,
                              external,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                        embedRecordWithMediaView: (recordWithMedia) =>
                            EmbedRecordWithMediaWidget(
                              widget.feed,
                              recordWithMedia,
                              width: embedWidth,
                              height: embedWidth,
                            ),
                        embedVideoView: (video) => EmbedVideoWidget(
                              widget.feed,
                              video,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                        unknown: (_) => const Text('unsupported embed')),
                  _buildFooter(post),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _tapMention(RichtextFacetMention feature) {
    context.read<Model>().setSearchKeyword(feature.did);
  }

  void _tapLink(RichtextFacetLink feature) {
    launchUrlPlus(feature.uri);
  }

  void _tapTag(RichtextFacetTag feature) {
    context.read<Model>().setSearchKeyword('#${feature.tag}');
  }

  Widget _buildRepost() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: const Row(
        children: [
          SizedBox(width: 40),
          Icon(Icons.repeat, size: 16, color: Colors.blueGrey),
          SizedBox(width: 8),
          Text('repost', style: TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildReply(bsky_feed.FeedViewPost feedView) {
    final post =
        (feedView.reply!.parent as bsky_feed.UReplyRefParentPostView).data;
    final author = post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${post.uri.rkey}';
    final root = (feedView.reply!.root as bsky_feed.UReplyRefRootPostView).data;

    return Row(
      children: [
        SizedBox(width: 36),
        Tooltip(
          message: 'View on Bluesky',
          waitDuration: Duration(milliseconds: 500),
          child: TextButton(
            onPressed: () => launchUrlPlus(postUrl),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Row(
              children: [
                Icon(Icons.reply, size: 16, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text('reply to ', style: TextStyle(color: Colors.blueGrey)),
                Text(displayName, style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
        ),
        Tooltip(
          message: 'Search reply chain',
          child: TextButton(
            onPressed: () =>
                context.read<Model>().setSearchKeyword(root.uri.toString()),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text('search', style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bsky_feed.PostView post) {
    final author = post.author;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${post.uri.rkey}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
          message: 'View on Bluesky',
          waitDuration: Duration(milliseconds: 500),
          child: TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Row(
              children: [
                Icon(Icons.open_in_browser, size: 16),
                SizedBox(width: 4),
                Text(DateFormat('H:mm yyyy-MM-dd')
                    .format(post.indexedAt.toLocal())),
              ],
            ),
            onPressed: () => launchUrlPlus(postUrl),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 16,
          height: 16,
          child: IconButton(
            icon: const Icon(Icons.today),
            iconSize: 16,
            padding: EdgeInsets.zero,
            tooltip: 'Search this day',
            onPressed: () {
              final day = post.indexedAt.toLocal();
              context.read<Model>().setSearchDay(day.year, day.month, day.day);
            },
          ),
        ),
      ],
    );
  }
}
