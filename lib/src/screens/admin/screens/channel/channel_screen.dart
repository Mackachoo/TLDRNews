import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/admin/screens/channel/channel_controller.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AdminChannelScreen extends StatelessWidget {
  const AdminChannelScreen({super.key, required this.cid});

  final String cid;

  @override
  Widget build(BuildContext context) {
    final ctlr = AdminChannelController(cid);
    return Container(
      color: context.colors.surface,
      padding: .all(16),
      child: ListenableBuilder(
        listenable: ctlr,
        builder: (context, child) {
          if (ctlr.loading) return const Center(child: CircularProgressIndicator());
          if (ctlr.channel == null) return const Center(child: Text('Channel not found'));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [headingTile(context, ctlr)],
          );
        },
      ),
    );
  }

  ListTile headingTile(BuildContext context, AdminChannelController ctlr) {
    return ListTile(
      leading: ctlr.snippet!.icon,
      title: Text('${ctlr.snippet!.name} Panel', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
