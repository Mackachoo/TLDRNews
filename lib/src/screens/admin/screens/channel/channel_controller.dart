import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/services/youtube_service.dart';
import 'package:tldrnews_app/src/utils/message.dart';

class AdminChannelController extends ChangeNotifier {
  bool loading = true;
  bool isFetching = false;

  final String cid;
  ChannelSnippet? get snippet => ChannelSnippets.byId(cid);

  Channel? original;
  Channel? channel;

  bool get editted =>
      channel != null && original != null && channel!.toJson() != original!.toJson();

  AdminChannelController(this.cid) {
    FirestoreService.channel.retrieve(cid).then((retrieved) {
      original = retrieved?.copy();
      channel = retrieved?.copy();
      loading = false;
      notifyListeners();
    });
  }

  Future saveChannel(BuildContext context) async {
    if (channel == null) return;
    try {
      await FirestoreService.channel.update(channel!);
      original = channel!.copy();
      if (context.mounted) Message.success(context, 'Channel saved successfully!');

      notifyListeners();
    } catch (error) {
      if (context.mounted) Message.error(context, error);

      notifyListeners();
    }
  }

  /// Adds a new video to the channel
  /// If the video already exists by ID, it will be updated
  Future<void> setVideo(YoutubeVideo video) async {
    if (channel == null) return;
    channel!.videos[video.id] = video;
    notifyListeners();
  }

  /// Adds a new series (playlist) to the channel
  /// If the series already exists by ID, it will be replaced
  Future<void> setSeries(Series newSeries) async {
    if (channel == null) return;
    channel!.series[newSeries.id] = newSeries;
    notifyListeners();
  }

  Future removeVideo(YoutubeVideo video) async {
    if (channel == null) return;
    channel!.videos.remove(video.id);
    notifyListeners();
  }

  Future removeSeries(Series series) async {
    if (channel == null) return;
    channel!.series.remove(series.id);
    notifyListeners();
  }

  /// Fetches videos and playlists from the channel's YouTube URL, adding only
  /// the ones the channel doesn't already have, and reports what was added.
  /// Existing videos and series are left untouched, and nothing is written to
  /// Firestore when there is nothing new.
  Future<void> fetchChannelConntentFromYoutube(BuildContext context) async {
    if (channel == null) {
      if (context.mounted) Message.error(context, 'Channel data not loaded yet');
      return;
    }

    if (channel!.channelUrl.isEmpty) {
      if (context.mounted) {
        Message.error(context, 'Channel URL is not set. Please configure the channel URL first.');
      }
      return;
    }

    try {
      debugPrint('AdminChannelController: Starting fetch for channel URL: ${channel!.channelUrl}');
      isFetching = true;
      notifyListeners();

      // Build sets of existing IDs to skip content that's already downloaded
      final existingVideoIds = channel!.videos.keys.toSet();
      final existingSeriesIds = channel!.series.keys.toSet();
      debugPrint(
        'AdminChannelController: Found ${existingVideoIds.length} existing videos and '
        '${existingSeriesIds.length} existing series, fetching new ones',
      );

      // Fetch content from YouTube, excluding existing IDs
      debugPrint('AdminChannelController: Calling YouTubeService.fetchChannelContent');
      final result = await YouTubeService.fetchChannelContent(
        channel!.channelUrl,
        excludeVideoIds: existingVideoIds,
        excludeSeriesIds: existingSeriesIds,
      );

      final videos = (result['videos'] as List? ?? []).cast<YoutubeVideo>();
      final series = (result['series'] as List? ?? []).cast<Series>();

      // The service already filters by the excluded IDs, but diff again here so
      // nothing existing can be overwritten
      final newVideos = videos.where((video) => !existingVideoIds.contains(video.id)).toList();
      final newSeries = series
          .where((playlist) => !existingSeriesIds.contains(playlist.id))
          .toList();

      debugPrint(
        'AdminChannelController: Fetched ${videos.length} videos and ${series.length} playlists, '
        'of which ${newVideos.length} videos and ${newSeries.length} series are new',
      );

      if (newVideos.isEmpty && newSeries.isEmpty) {
        debugPrint('AdminChannelController: Nothing new to add, skipping Firestore write');
        if (context.mounted) {
          Message.info(context, 'No new videos or playlists found — channel is up to date.');
        }
        isFetching = false;
        notifyListeners();
        return;
      }

      // Add the new content alongside the existing (most recent first due to
      // YouTube service sorting)
      for (final video in newVideos) {
        channel!.videos[video.id] = video;
      }
      for (final playlist in newSeries) {
        channel!.series[playlist.id] = playlist;
      }

      debugPrint('AdminChannelController: Updated channel object. Persisting to Firestore...');

      // Persist changes to Firestore immediately
      await FirestoreService.channel.set(channel!, merge: true);
      original = channel!.copy();

      debugPrint('AdminChannelController: Successfully saved to Firestore');

      if (context.mounted) {
        Message.success(context, 'Added ${_addedSummary(newVideos.length, newSeries.length)}!');
      }
      isFetching = false;
      notifyListeners();
    } catch (error) {
      debugPrint('AdminChannelController: Error during fetch: $error');
      if (context.mounted) Message.error(context, 'Error fetching content: $error');
      isFetching = false;
      notifyListeners();
    }
  }

  /// e.g. '3 new videos and 1 new playlist', omitting whichever count is zero
  String _addedSummary(int videoCount, int seriesCount) {
    final parts = [
      if (videoCount > 0) '$videoCount new ${videoCount == 1 ? 'video' : 'videos'}',
      if (seriesCount > 0) '$seriesCount new ${seriesCount == 1 ? 'playlist' : 'playlists'}',
    ];
    return parts.join(' and ');
  }
}
