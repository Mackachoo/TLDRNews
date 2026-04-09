import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';

class VideoList extends StatelessWidget {
  const VideoList(this.ctlr, {super.key});

  final ChannelController ctlr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ctlr.channel!.videos.entries
          .map((entry) => ListTile(title: Text(entry.value.title)))
          .toList(),
    );
  }
}
