import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
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

          return SingleChildScrollView(
            child: Flex(
              direction: MediaQuery.of(context).orientation == .portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 32,
              children: MediaQuery.of(context).orientation == .portrait
                  ? [primary(context, ctlr), secondary(context, ctlr)]
                  : [
                      Expanded(flex: 1, child: primary(context, ctlr)),
                      Expanded(flex: 2, child: secondary(context, ctlr)),
                    ],
            ),
          );
        },
      ),
    );
  }

  // * Primary Column ------------------------------------------------------------

  Column primary(BuildContext context, AdminChannelController ctlr) => Column(
    spacing: 16,
    mainAxisSize: MainAxisSize.min,
    children: [
      headingTile(context, ctlr),
      saveTile(context, ctlr),
      crmActionBar(context, ctlr),
      if (ctlr.errorMessage.isNotEmpty || ctlr.successMessage.isNotEmpty)
        messageCard(context, ctlr),
    ],
  );

  ListTile headingTile(BuildContext context, AdminChannelController ctlr) {
    return ListTile(
      leading: ctlr.snippet!.icon,
      title: Text('${ctlr.snippet!.name} Panel', style: Theme.of(context).textTheme.headlineMedium),
    );
  }

  Widget crmActionBar(BuildContext context, AdminChannelController ctlr) {
    return ListTile(
      leading: PhosphorIcon(PhosphorIcons.cloudArrowDown()),
      title: const Text('Content Management'),
      subtitle: const Text('Fetch videos and playlists from YouTube'),
      trailing: ctlr.isFetching
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : ElevatedButton.icon(
              onPressed: () => ctlr.fetchChannelConntentFromYoutube(),
              icon: PhosphorIcon(PhosphorIcons.download()),
              label: const Text('Fetch'),
            ),
    );
  }

  Widget messageCard(BuildContext context, AdminChannelController ctlr) {
    if (ctlr.errorMessage.isEmpty && ctlr.successMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = ctlr.errorMessage.isNotEmpty;
    final message = isError ? ctlr.errorMessage : ctlr.successMessage;
    final color = isError ? context.colors.error : context.colors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  ListTile saveTile(BuildContext context, AdminChannelController ctlr) {
    return ListTile(
      leading: PhosphorIcon(PhosphorIcons.floppyDisk()),
      title: Text('Save Changes', style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text('Persist changes to Firestore', style: Theme.of(context).textTheme.bodySmall),
      trailing: ElevatedButton(onPressed: () => ctlr.saveChannel(), child: const Text('Save')),
    );
  }

  // * Secondary Column ------------------------------------------------------------

  Column secondary(BuildContext context, AdminChannelController ctlr) => Column(
    mainAxisSize: MainAxisSize.min,
    children: ctlr.channel?.videos.values.map((video) => videoCard(context, video)).toList() ?? [],
  );

  Widget videoCard(BuildContext context, YoutubeVideo video) {
    bool expanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: video.imageUrl != null
                  ? Image.network(video.imageUrl!, width: 100, fit: BoxFit.cover)
                  : null,
              title: Text(video.title, style: Theme.of(context).textTheme.bodyMedium),
              trailing: PhosphorIcon(
                expanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
                size: 16,
              ),
              onTap: () => setState(() => expanded = !expanded),
            ),

            if (expanded) ...[
              const SizedBox(height: 4),
              Text(video.id, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        );
      },
    );
  }
}
