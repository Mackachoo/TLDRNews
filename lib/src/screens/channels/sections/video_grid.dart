import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/channels/widgets/video_widget.dart';

class VideoGrid extends StatelessWidget {
  const VideoGrid(this.ctlr, {super.key});

  final ChannelController ctlr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: (MediaQuery.of(context).size.width / 200).floor().clamp(1, 4),

        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: ctlr.channel!.videos.entries.map((entry) => VideoWidget(entry.value)).toList(),
      ),
    );
  }
}
