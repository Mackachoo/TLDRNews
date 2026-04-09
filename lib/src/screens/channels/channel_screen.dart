import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/channels/sections/series_list.dart';
import 'package:tldrnews_app/src/screens/channels/sections/video_grid.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key, required this.channelId});

  final String channelId;
  ChannelSnippet? get snippet => ChannelSnippets.byId(channelId);

  @override
  Widget build(BuildContext context) {
    if (snippet == null) return unknownChannel(context);
    ChannelController ctlr = App.ctlr.channel(snippet!);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(text: 'Videos'),
            Tab(text: 'Series'),
          ],
        ),
        body: ListenableBuilder(
          listenable: ctlr,
          builder: (context, child) {
            if (ctlr.loading) return const Center(child: CircularProgressIndicator());
            if (ctlr.channel == null) return unknownChannel(context);

            return TabBarView(children: [VideoGrid(ctlr), SeriesList(ctlr)]);
          },
        ),
      ),
    );
  }

  Center unknownChannel(BuildContext context) =>
      Center(child: Text('Channel not found', style: context.textTheme.headlineSmall));
}
