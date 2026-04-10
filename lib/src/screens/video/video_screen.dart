import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;

class VideoScreen extends StatefulWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  late yt.YoutubePlayerController _youtubeController;
  ChewieController? _chewieController;
  bool _isYoutubeVideo = false;
  bool _isInitialized = false;
  Video? _video;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _findAndInitializeVideo();
  }

  Future<void> _findAndInitializeVideo() async {
    try {
      // Search through all loaded channels for this video
      Video? foundVideo;
      for (final channelCtlr in App.ctlr.channels.values) {
        foundVideo = channelCtlr.channel?.videos[widget.videoId];
        if (foundVideo != null) break;
      }

      if (foundVideo == null) {
        setState(() {
          _errorMessage = 'Video not found';
          _isInitialized = true;
        });
        return;
      }

      _video = foundVideo;
      await _initializeVideo(foundVideo);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: ${e.toString()}';
        _isInitialized = true;
      });
    }
  }

  Future<void> _initializeVideo(Video video) async {
    final url = video.youtubeUrl;
    final videoId = yt.YoutubePlayer.convertUrlToId(url);

    if (videoId != null && !kIsWeb) {
      // It's a YouTube URL and we're on native platform
      _isYoutubeVideo = true;
      _youtubeController = yt.YoutubePlayerController(
        initialVideoId: videoId,
        flags: const yt.YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    } else if (videoId != null && kIsWeb) {
      // YouTube URL on web - mark as YouTube (will show link in UI)
      _isYoutubeVideo = true;
    } else {
      // Assume it's a direct video URL
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    if (_isYoutubeVideo && !kIsWeb) {
      _youtubeController.dispose();
    } else {
      _chewieController?.dispose();
      if (!_isYoutubeVideo) {
        _videoPlayerController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Player')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_video == null) {
      return const Scaffold(body: Center(child: Text('Video not found')));
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(_video!.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isYoutubeVideo && !kIsWeb)
              yt.YoutubePlayer(controller: _youtubeController, showVideoProgressIndicator: true)
            else if (_isYoutubeVideo && kIsWeb)
              _buildWebYoutubePlayer()
            else if (_chewieController != null)
              Chewie(controller: _chewieController!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_video!.title, style: Theme.of(context).textTheme.titleLarge),
                  if (_video!.description != null) ...[
                    const SizedBox(height: 8),
                    Text(_video!.description!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebYoutubePlayer() {
    final videoId = yt.YoutubePlayer.convertUrlToId(_video!.youtubeUrl);
    if (videoId == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Invalid YouTube URL')),
      );
    }

    // On web, provide a direct link to YouTube
    return Container(
      height: 300,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'YouTube Video',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open YouTube in new tab/window
                final url = _video!.youtubeUrl;
                // For web, you could use 'dart:html' to open the URL
                // For now, just show the URL
                debugPrint('YouTube URL: $url');
              },
              child: const Text('Open on YouTube'),
            ),
          ],
        ),
      ),
    );
  }
}
