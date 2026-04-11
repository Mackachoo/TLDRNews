import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/channels/widgets/video_widget.dart';
import 'package:tldrnews_app/src/widgets/responsive_grid.dart';

class VideoGrid extends StatelessWidget {
  const VideoGrid(this.ctlr, {super.key});

  final ChannelController ctlr;

  @override
  Widget build(BuildContext context) {
    final videos = ctlr.channel!.videos.values.map((video) => VideoWidget(video)).toList();

    return ResponsiveGrid(
      minItemWidth: 200,
      maxCrossAxisCount: 4,
      children: videos
        ..sort((a, b) {
          if (a.video.published == null && b.video.published == null) return 0;
          if (a.video.published == null) return 1; // null goes to end
          if (b.video.published == null) return -1; // null goes to end

          return b.video.published!.compareTo(a.video.published!);
        }),
    );
  }
}
