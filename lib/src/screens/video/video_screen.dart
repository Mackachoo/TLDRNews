import 'package:material_ui/material_ui.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/youtube_player.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  (Channel, YoutubeVideo)? retrieveVideo() {
    for (final channelCtlr in App.ctlr.channels.values) {
      final video = channelCtlr.channel?.videos[videoId];
      if (video != null) return (channelCtlr.channel!, video);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final result = retrieveVideo();

    if (result == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sorry, this video was not found. It may have been removed or is not available.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final (channel, video) = result;

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
