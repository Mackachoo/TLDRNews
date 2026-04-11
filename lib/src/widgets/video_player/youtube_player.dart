import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayer extends StatelessWidget {
  const YoutubeVideoPlayer(this.video, {super.key});

  final YoutubeVideo video;

  @override
  Widget build(BuildContext context) {
    final _controller = YoutubePlayerController.fromVideoId(
      videoId: video.id,
      params: YoutubePlayerParams(mute: false, showControls: true, showFullscreenButton: true),
    );
    return YoutubePlayer(controller: _controller, aspectRatio: 16 / 9);
  }
}
