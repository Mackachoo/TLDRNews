import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Plays a [YoutubeVideo] with a 16:9 surface and built-in controls.
///
/// Fullscreen is handled internally by the player, so no scaffold or builder
/// wrapper is needed around it.
class YoutubeVideoPlayer extends StatefulWidget {
  const YoutubeVideoPlayer(this.video, {super.key});

  final YoutubeVideo video;

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late final YoutubePlayerController _ctlr = YoutubePlayerController.fromVideoId(
    videoId: widget.video.id,
    params: const YoutubePlayerParams(
      mute: false,
      enableCaption: true,
      showControls: true,
      showFullscreenButton: true,
      origin: 'https://www.youtube-nocookie.com',
    ),
  );

  @override
  void dispose() {
    _ctlr.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => YoutubePlayer(controller: _ctlr);
}
