import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/screens/admin/screens/channel/channel_controller.dart';
import 'package:tldrnews_app/src/screens/admin/screens/channel/widgets/content_editor.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AdminChannelScreen extends StatefulWidget {
  const AdminChannelScreen({super.key, required this.cid});

  final String cid;

  @override
  State<AdminChannelScreen> createState() => _AdminChannelScreenState();
}

class _AdminChannelScreenState extends State<AdminChannelScreen> {
  late final AdminChannelController ctlr;
  late bool deleteMode;

  @override
  void initState() {
    super.initState();
    ctlr = AdminChannelController(widget.cid);
    deleteMode = false;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == .portrait;

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
              direction: isPortrait ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                commandCard(),
                videosCard(),
                seriesCard(),
              ].map((c) => isPortrait ? c : Expanded(child: c)).toList(),
            ),
          );
        },
      ),
    );
  }

  ListTile headingTile() {
    return ListTile(
      contentPadding: .all(16),
      leading: ctlr.snippet!.icon,
      title: Text('${ctlr.snippet!.name} Panel', style: Theme.of(context).textTheme.headlineMedium),
    );
  }

  // * Commands Card ------------------------------------------------------------
  Widget commandCard() => Card(
    child: SizedBox(
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [headingTile(), saveTile(), deleteModeTile(), crmActionBar()],
      ),
    ),
  );

  Widget crmActionBar() {
    return ListTile(
      leading: PhosphorIcon(PhosphorIcons.cloudArrowDown()),
      title: const Text('Youtube Content'),
      subtitle: const Text('Fetch recent videos and playlists from YouTube'),
      trailing: ctlr.isFetching
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : ElevatedButton.icon(
              onPressed: () => ctlr.fetchChannelConntentFromYoutube(context),
              icon: PhosphorIcon(PhosphorIcons.download()),
              label: const Text('Fetch'),
            ),
    );
  }

  Widget saveTile() {
    return Container(
      color: ctlr.editted ? context.colors.primaryContainer : context.colors.surfaceContainerLow,
      child: ListTile(
        leading: PhosphorIcon(PhosphorIcons.floppyDisk()),
        title: Text('Save Changes', style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          'Persist changes to Firestore',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: ElevatedButton(
          onPressed: () => ctlr.saveChannel(context),
          child: const Text('Save'),
        ),
      ),
    );
  }

  Widget deleteModeTile() {
    return Container(
      color: deleteMode ? context.colors.errorContainer : context.colors.surfaceContainerLow,
      child: ListTile(
        leading: PhosphorIcon(PhosphorIcons.floppyDisk()),
        title: Text('Delete Mode', style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          'Enable deletion of videos and series from the channel',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: ElevatedButton(
          onPressed: () => setState(() => deleteMode = !deleteMode),
          child: Text(deleteMode ? 'Deactivate' : 'Activate'),
        ),
      ),
    );
  }

  // * Videos Card ------------------------------------------------------------

  bool videoCardExpanded = true;
  Widget videosCard() => Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Videos', style: context.textTheme.headlineSmall),
          trailing: PhosphorIcon(
            !videoCardExpanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
          ),
          onTap: () => setState(() => videoCardExpanded = !videoCardExpanded),
        ),
        if (videoCardExpanded)
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.plus()),
            title: const Text('Add new video'),
            onTap: () => ContentEditor.video(context, ctlr),
          ),
        if (videoCardExpanded)
          ...?(ctlr.channel?.videos.values.toList()
                ?..sort((a, b) => b.published!.compareTo(a.published!)))
              ?.map((video) => videoTile(video)),
        if (videoCardExpanded && ctlr.channel?.videos.isEmpty == true)
          Padding(
            padding: .all(16),
            child: Text('No videos found', style: Theme.of(context).textTheme.bodyMedium),
          ),
      ],
    ),
  );

  Widget videoTile(YoutubeVideo video) => ListTile(
    contentPadding: .all(8),
    leading: video.imageUrl != null
        ? Image.network(video.imageUrl!, width: 100, fit: BoxFit.cover)
        : null,
    title: Text(video.title, style: Theme.of(context).textTheme.bodyMedium),
    trailing: PhosphorIcon(deleteMode ? PhosphorIcons.trash() : PhosphorIcons.caretRight()),
    onTap: () => deleteMode ? ctlr.removeVideo(video) : ContentEditor.video(context, ctlr, video),
  );

  // * Series Card ------------------------------------------------------------

  bool seriesCardExpanded = true;
  Widget seriesCard() => Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Series', style: context.textTheme.headlineSmall),
          trailing: PhosphorIcon(
            seriesCardExpanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
          ),
          onTap: () => setState(() => seriesCardExpanded = !seriesCardExpanded),
        ),
        if (seriesCardExpanded)
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.plus()),
            title: const Text('Add new series'),
            onTap: () => ContentEditor.series(context, ctlr),
          ),

        if (seriesCardExpanded)
          ...?(ctlr.channel?.series.values.toList()
                ?..sort((a, b) => b.published!.compareTo(a.published!)))
              ?.map((series) => seriesTile(series)),
        if (seriesCardExpanded && ctlr.channel?.series.isEmpty == true)
          Padding(
            padding: .all(16),
            child: Text('No series found', style: Theme.of(context).textTheme.bodyMedium),
          ),
      ],
    ),
  );

  Widget seriesTile(Series series) => ListTile(
    contentPadding: .all(8),
    leading: series.imageUrl != null
        ? Image.network(series.imageUrl!, width: 100, fit: BoxFit.cover)
        : null,
    title: Text(series.title, style: Theme.of(context).textTheme.bodyMedium),
    trailing: PhosphorIcon(deleteMode ? PhosphorIcons.trash() : PhosphorIcons.caretRight()),
    onTap: () =>
        deleteMode ? ctlr.removeSeries(series) : ContentEditor.series(context, ctlr, series),
  );
}
