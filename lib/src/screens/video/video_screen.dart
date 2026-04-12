import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/video_players/youtube_player.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    final result = retrieveVideo();

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unknown Video')),
        body: const Center(
          child: Text(
            'Sorry, this video was not found. It may have been removed or is not available.',
          ),
        ),
      );
    }
    final channel = result.$1;
    final video = result.$2;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(video.title)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
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
                        Text(video.title, style: Theme.of(context).textTheme.titleLarge),
                        Align(
                          alignment: .centerRight,
                          child: Text(
                            [(channel.name), video.published?.toLocal().toUI()].join(' • '),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (video.description != null) ...[
                          const SizedBox(height: 8),
                          Text(video.description!, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Channel, YoutubeVideo)? retrieveVideo() {
    for (final channelCtlr in App.ctlr.channels.values) {
      final video = channelCtlr.channel?.videos[videoId];
      if (video != null) return (channelCtlr.channel!, video);
    }
    return null;
  }
}
