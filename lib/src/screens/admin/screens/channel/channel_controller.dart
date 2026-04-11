import 'package:flutter/material.dart';
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
      original = retrieved;
      channel = retrieved;
      loading = false;
      notifyListeners();
    });
  }

  Future saveChannel(BuildContext context) async {
    if (channel == null) return;
    try {
      await FirestoreService.channel.update(channel!);
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

  /// Fetches videos and playlists from the channel's YouTube URL
  /// and updates both the local channel object and Firestore
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

      // Build set of existing video IDs to skip already-downloaded videos
      final existingVideoIds = channel!.videos.keys.toSet();
      debugPrint(
        'AdminChannelController: Found ${existingVideoIds.length} existing videos, fetching new ones',
      );

      // Fetch content from YouTube, excluding existing IDs
      debugPrint('AdminChannelController: Calling YouTubeService.fetchChannelContent');
      final result = await YouTubeService.fetchChannelContent(
        channel!.channelUrl,
        excludeVideoIds: existingVideoIds,
      );

      final videos = result['videos'] as List? ?? [];
      final series = result['series'] as List? ?? [];

      debugPrint(
        'AdminChannelController: Fetched ${videos.length} new videos and ${series.length} playlists',
      );

      // Add new videos to existing ones (most recent first due to YouTube service sorting)
      for (final video in videos) {
        channel!.videos[video.id] = video;
      }

      // Replace series with fresh list
      channel!.series.clear();
      for (final playlist in series) {
        channel!.series[playlist.id] = playlist;
      }

      debugPrint('AdminChannelController: Updated channel object. Persisting to Firestore...');

      // Persist changes to Firestore immediately
      await FirestoreService.channel.set(channel!, merge: true);

      debugPrint('AdminChannelController: Successfully saved to Firestore');

      if (context.mounted) {
        Message.success(
          context,
          'Successfully fetched ${videos.length} videos and ${series.length} playlists!',
        );
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
}
