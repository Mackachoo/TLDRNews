import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class WebVideoPlayer extends StatefulWidget {
  const WebVideoPlayer(this.video, {super.key});

  final YoutubeVideo video;

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initYoutubeIframe();
  }

  void _initYoutubeIframe() {
    final videoId = yt.YoutubePlayer.convertUrlToId(widget.video.videoUrl);
    if (videoId == null) return;

    _videoId = videoId;
    _registerIframe(videoId);
  }

  void _registerIframe(String videoId) {
    try {
      ui_web.platformViewRegistry.registerViewFactory('youtube-iframe-$videoId', (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('allow', 'autoplay');
        return iframe;
      });
    } catch (e) {
      debugPrint('Error registering YouTube iframe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return const Center(child: Text('Invalid YouTube URL'));
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: HtmlElementView(viewType: 'youtube-iframe-$_videoId'),
    );
  }
}
