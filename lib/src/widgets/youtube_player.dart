import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Plays a [YoutubeVideo] with a 16:9 surface and built-in controls.
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
  void initState() {
    super.initState();
    if (!kIsWeb) _ctlr.setFullScreenListener(_onFullscreenChanged);
  }

  void _onFullscreenChanged(bool isFullscreen) {
    if (isFullscreen) {
      if (_ctlr.value.fullScreenOption.locked) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _restoreOrientation();
    }
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    // In case the screen is left mid-fullscreen (e.g. by navigating away),
    // make sure the rest of the app doesn't stay locked to landscape.
    if (!kIsWeb) _restoreOrientation();
    _ctlr.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => YoutubePlayer(controller: _ctlr);
}
