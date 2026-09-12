import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/objects/channel/video_block.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/screens/channels/video_paging.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/services/functions_service.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/utils/message.dart';

class AdminChannelController extends ChangeNotifier with VideoPaging {
  bool loading = true;
  bool isFetching = false;

  @override
  final String cid;
  ChannelSnippet? get snippet => ChannelSnippets.byId(cid);

  Channel? original;
  Channel? channel;

  /// Ids of blocks edited since the last save.
  final Set<String> dirtyBlocks = {};

  bool get editted => dirtyBlocks.isNotEmpty || _channelEditted;

  bool get _channelEditted =>
      channel != null && original != null && channel!.toJson() != original!.toJson();

  AdminChannelController(this.cid) {
    _load();
  }

  Future<void> _load() async {
    final retrieved = await FirestoreService.channel.retrieve(cid);
    original = retrieved?.copy();
    channel = retrieved?.copy();
    await loadNewestBlock();
    loading = false;
    notifyListeners();
  }

  //* Editing ----------------------------------------------------------

  Future saveChannel(BuildContext context) async {
    if (channel == null) return;
    try {
      if (_channelEditted) await FirestoreService.channel.update(channel!);

      for (final block in blocks.where((block) => dirtyBlocks.contains(block.id))) {
        await FirestoreService.channel.setVideoBlock(cid, block);
      }

      dirtyBlocks.clear();
      original = channel!.copy();
      if (context.mounted) Message.success(context, 'Channel saved successfully!');
    } catch (error) {
      if (context.mounted) Message.error(context, error);
    }
    notifyListeners();
  }

  /// Adds or replaces a video in whichever loaded block covers its date.
  Future<void> setVideo(YoutubeVideo video) async {
    final block = _blockFor(video);
    if (block == null) return;

    block.videos[video.id] = video;
    dirtyBlocks.add(block.id);
    rebuildVideos();
    notifyListeners();
  }

  Future removeVideo(YoutubeVideo video) async {
    final block = blocks.firstWhereOrNull((block) => block.videos.containsKey(video.id));
    if (block == null) return;

    block.videos.remove(video.id);
    dirtyBlocks.add(block.id);
    rebuildVideos();
    notifyListeners();
  }

  Future<void> setSeries(Series newSeries) async {
    if (channel == null) return;
    channel!.series[newSeries.id] = newSeries;
    notifyListeners();
  }

  Future removeSeries(Series series) async {
    if (channel == null) return;
    channel!.series.remove(series.id);
    notifyListeners();
  }

  //* Youtube Ingest ---------------------------------------------------

  /// Runs the sync function, which fetches from YouTube and writes the blocks.
  /// [rebuild] discards the stored blocks and re-downloads the full history.
  Future<void> fetchChannelContentFromYoutube(BuildContext context, {bool rebuild = false}) async {
    isFetching = true;
    notifyListeners();

    final result = await FunctionsService.syncChannel(cid, rebuild: rebuild);

    if (result == null) {
      if (context.mounted) Message.error(context, 'Could not sync this channel from YouTube.');
    } else {
      final added = _addedSummary(result['addedVideos'] as int?, result['addedSeries'] as int?);
      await _reload();
      if (context.mounted) {
        Message.success(
          context,
          added.isEmpty ? 'Channel is already up to date.' : 'Added $added!',
        );
      }
    }

    isFetching = false;
    notifyListeners();
  }

  //* Private Methods --------------------------------------------------

  Future<void> _reload() async {
    resetPaging();
    dirtyBlocks.clear();
    final retrieved = await FirestoreService.channel.retrieve(cid, useCache: false);
    original = retrieved?.copy();
    channel = retrieved?.copy();
    await loadNewestBlock();
  }

  /// Blocks are held newest first, so the first one starting at or before the
  /// video's date is the one covering it.
  VideoBlock? _blockFor(YoutubeVideo video) {
    final existing = blocks.firstWhereOrNull((block) => block.videos.containsKey(video.id));
    if (existing != null) return existing;

    final published = video.published;
    if (published == null) return blocks.firstOrNull;

    return blocks.firstWhereOrNull((block) => !block.startAt.isAfter(published)) ??
        blocks.lastOrNull;
  }

  /// e.g. '3 new videos and 1 new playlist', omitting whichever count is zero
  String _addedSummary(int? videoCount, int? seriesCount) {
    final videos = videoCount ?? 0;
    final series = seriesCount ?? 0;
    final parts = [
      if (videos > 0) '$videos new ${videos == 1 ? 'video' : 'videos'}',
      if (series > 0) '$series new ${series == 1 ? 'playlist' : 'playlists'}',
    ];
    return parts.join(' and ');
  }
}
