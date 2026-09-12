import 'package:material_ui/material_ui.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/youtube_player.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final Future<(Channel, YoutubeVideo)?> video = retrieveVideo();

  /// Blocks already paged in answer immediately; anything else — a shared link,
  /// or a video too old to have been scrolled to — is found by its block.
  Future<(Channel, YoutubeVideo)?> retrieveVideo() async {
    for (final channelCtlr in App.ctlr.channels.values) {
      final channel = channelCtlr.channel;
      if (channel == null) continue;
      for (final block in channelCtlr.blocks) {
        final video = block.videos[widget.videoId];
        if (video != null) return (channel, video);
      }
    }

    final found = await FirestoreService.channel.blockContainingVideo(widget.videoId);
    if (found == null) return null;

    final (cid, block) = found;
    final channel = await FirestoreService.channel.retrieve(cid);
    final video = block.videos[widget.videoId];
    if (channel == null || video == null) return null;

    return (channel, video);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: video,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data;
        if (result == null) return unknownVideo();

        final (channel, video) = result;
        return details(context, channel, video);
      },
    );
  }

  Widget unknownVideo() => const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Sorry, this video was not found. It may have been removed or is not available.',
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget details(BuildContext context, Channel channel, YoutubeVideo video) {
    return SingleChildScrollView(
      child: Container(
        alignment: .topCenter,
        padding: .symmetric(vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              YoutubeVideoPlayer(video),
              Card(
                margin: .only(top: 16),
                child: Container(
                  padding: .all(16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title, style: context.textTheme.titleLarge),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          [(channel.name), video.published?.toLocal().toUI()].join(' • '),
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (video.description != null) ...[
                        const SizedBox(height: 8),
                        Linkify(
                          onOpen: (link) async {
                            if (await canLaunchUrl(Uri.parse(link.url))) {
                              await launchUrl(
                                Uri.parse(link.url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          text: video.description!,
                          style: context.textTheme.bodyMedium,
                          linkStyle: context.textTheme.bodyMedium?.copyWith(
                            color: context.theme.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
