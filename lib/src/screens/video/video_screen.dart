import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/app_shell.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/utils/youtube_controller.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  void initState() {
    super.initState();
    // Switch to full-screen mode when this screen is displayed
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => App.ctlr.youtube.displayMode = PlayerDisplayMode.fullScreen,
    );
  }

  @override
  void dispose() {
    // Switch back to floating mode when leaving
    App.ctlr.youtube.displayMode = PlayerDisplayMode.floating;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = retrieveVideo();

  (Channel, YoutubeVideo)? retrieveVideo() {
    for (final channelCtlr in App.ctlr.channels.values) {
      final video = channelCtlr.channel?.videos[widget.videoId];
      if (video != null) return (channelCtlr.channel!, video);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null || _controller == null) {
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
    App.ctlr.youtube.start(video.id);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(video.title)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                App.ctlr.youtube.player(),
                // YoutubeVideoPlayer(video),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (Channel, YoutubeVideo)? retrieveVideo() {
    for (final channelCtlr in App.ctlr.channels.values) {
      final video = channelCtlr.channel?.videos[widget.videoId];
      if (video != null) return (channelCtlr.channel!, video);
    }
    return null;
  }
}
