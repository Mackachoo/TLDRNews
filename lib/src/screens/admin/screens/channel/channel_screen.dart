import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';
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

  /// A ListTile leading must be hard-sized. An unbounded one expands to the
  /// full tile width, which trips ListTile's layout assert and then poisons hit
  /// testing for the rest of the page. ChannelIcon is a bare AspectRatio, so it
  /// fills whatever width it is offered.
  Widget leadingBox(Widget child) => SizedBox.square(dimension: 40, child: child);

  /// Thumbnails are hard-sized for the same reason, and fall back to a
  /// placeholder because YouTube returns 404 for pulled videos.
  Widget thumbnail(String url) => SizedBox(
    width: 100,
    height: 56,
    child: Image.network(
      url,
      width: 100,
      height: 56,
      fit: BoxFit.cover,
      // Decode at display size. hqdefault.jpg is 480x360, so without this each
      // 100px thumbnail holds a ~690KB texture, and this page renders 50 of them.
      cacheWidth: 200,
      cacheHeight: 112,
      errorBuilder: (context, error, stackTrace) => Container(
        color: context.colors.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported, size: 20, color: context.colors.onSurfaceVariant),
      ),
    ),
  );

  ListTile headingTile() {
    return ListTile(
      contentPadding: .all(16),
      leading: leadingBox(ctlr.snippet!.icon),
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
      leading: const Icon(Icons.cloud_download),
      title: const Text('Youtube Content'),
      subtitle: Text(
        ctlr.channel?.channelUrl.isNotEmpty == true
            ? 'Fetches from ${ctlr.channel!.channelUrl}'
            : 'No channel URL set',
      ),
      trailing: ctlr.isFetching
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                TextButton(onPressed: () => confirmRebuild(), child: const Text('Rebuild')),
                ElevatedButton.icon(
                  onPressed: () => ctlr.fetchChannelContentFromYoutube(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Fetch'),
                ),
              ],
            ),
    );
  }

  Widget saveTile() {
    return Material(
      color: ctlr.editted ? context.colors.primaryContainer : context.colors.surfaceContainerLow,
      child: ListTile(
        leading: const Icon(Icons.save),
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
    return Material(
      color: deleteMode ? context.colors.errorContainer : context.colors.surfaceContainerLow,
      child: ListTile(
        leading: const Icon(Icons.save),
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
          trailing: Icon(!videoCardExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => videoCardExpanded = !videoCardExpanded),
        ),
        if (videoCardExpanded)
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add new video'),
            onTap: () => ContentEditor.video(context, ctlr),
          ),
        if (videoCardExpanded) ...ctlr.videos.map((video) => videoTile(video)),
        if (videoCardExpanded && ctlr.videos.isEmpty)
          Padding(
            padding: .all(16),
            child: Text('No videos found', style: Theme.of(context).textTheme.bodyMedium),
          ),
        if (videoCardExpanded && ctlr.hasMore) loadMoreTile(),
      ],
    ),
  );

  Widget videoTile(YoutubeVideo video) => ListTile(
    contentPadding: .all(8),
    leading: video.imageUrl == null ? null : thumbnail(video.imageUrl!),
    title: Text(video.title, style: Theme.of(context).textTheme.bodyMedium),
    trailing: Icon(deleteMode ? Icons.delete : Icons.chevron_right),
    onTap: () => deleteMode ? ctlr.removeVideo(video) : ContentEditor.video(context, ctlr, video),
  );

  Widget loadMoreTile() => ListTile(
    leading: ctlr.loadingMore
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : const Icon(Icons.expand_more),
    title: const Text('Load older videos'),
    onTap: ctlr.loadingMore ? null : () => ctlr.loadMoreVideos(),
  );

  /// A rebuild throws away the stored blocks, so it asks first.
  Future<void> confirmRebuild() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rebuild from YouTube?'),
        content: const Text(
          'This deletes every stored video block for this channel and downloads '
          'the full history again. Local edits will be lost.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rebuild'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ctlr.fetchChannelContentFromYoutube(context, rebuild: true);
    }
  }

  // * Series Card ------------------------------------------------------------

  bool seriesCardExpanded = true;
  Widget seriesCard() => Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Series', style: context.textTheme.headlineSmall),
          trailing: Icon(seriesCardExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => seriesCardExpanded = !seriesCardExpanded),
        ),
        if (seriesCardExpanded)
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add new series'),
            onTap: () => ContentEditor.series(context, ctlr),
          ),

        if (seriesCardExpanded)
          ...?(ctlr.channel?.series.values.toList()?..sort(Content.byPublishedDesc))?.map(
            (series) => seriesTile(series),
          ),
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
    leading: series.imageUrl != null ? thumbnail(series.imageUrl!) : null,
    title: Text(series.title, style: Theme.of(context).textTheme.bodyMedium),
    trailing: Icon(deleteMode ? Icons.delete : Icons.chevron_right),
    onTap: () =>
        deleteMode ? ctlr.removeSeries(series) : ContentEditor.series(context, ctlr, series),
  );
}
