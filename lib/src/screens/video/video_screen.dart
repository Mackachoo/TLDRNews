import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/app_shell.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen(this.videoId, {super.key});

  final String videoId;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController? _controller;
  (Channel, YoutubeVideo)? _result;

  @override
  void initState() {
    super.initState();
    _result = retrieveVideo();

    if (_result != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _result!.$2.id,
        params: const YoutubePlayerParams(
          mute: false,
          enableCaption: true,
          showControls: true,
          showFullscreenButton: true,
          origin: 'https://www.youtube-nocookie.com',
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

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

    final channel = _result!.$1;
    final video = _result!.$2;

    return YoutubePlayerScaffold(
      controller: _controller!,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return AppShell(
          child: SingleChildScrollView(
            child: Container(
              alignment: .topCenter,
              padding: .symmetric(vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    player,
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
                              alignment: Alignment.centerRight,
                              child: Text(
                                [(channel.name), video.published?.toLocal().toUI()].join(' • '),
                                style: Theme.of(context).textTheme.bodyMedium,
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
                                style: Theme.of(context).textTheme.bodyMedium,
                                linkStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
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
          ),
        );
      },
    );
  }
}
