import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/channels/widgets/series_widget.dart';

class SeriesList extends StatelessWidget {
  const SeriesList(this.ctlr, {super.key});

  final ChannelController ctlr;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: .all(16),
      shrinkWrap: true,
      children: ctlr.channel!.series.entries.map((entry) => SeriesWidget(entry.value)).toList(),
    );
  }
}
