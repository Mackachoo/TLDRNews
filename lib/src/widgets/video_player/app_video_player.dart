import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer(this.video, {super.key});

  final YoutubeVideo video;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late YoutubePlayerController _youtubeController;
  ChewieController? _chewieController;
  bool _isYoutube = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.video.videoUrl;
    final videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
    }

    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    if (_isYoutube) {
      _youtubeController.dispose();
    } else {
      _chewieController?.dispose();
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isYoutube) {
      return YoutubePlayer(controller: _youtubeController, showVideoProgressIndicator: true);
    }

    return Chewie(controller: _chewieController!);
  }
}
