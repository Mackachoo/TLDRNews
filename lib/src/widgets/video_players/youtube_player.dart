import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayer extends StatelessWidget {
  const YoutubeVideoPlayer(this.video, {super.key});

  final YoutubeVideo video;

  @override
  Widget build(BuildContext context) {
    final ctlr = YoutubePlayerController.fromVideoId(
      videoId: video.id,
      params: const YoutubePlayerParams(
        mute: false,
        enableCaption: true,
        showControls: true,
        showFullscreenButton: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    return YoutubePlayer(controller: ctlr, aspectRatio: 16 / 9);
  }
}
