import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/services/youtube_service.dart';

class AdminChannelController extends ChangeNotifier {
  bool loading = true;
  bool isFetching = false;
  String errorMessage = '';
  String successMessage = '';

  final String cid;
  ChannelSnippet? get snippet => ChannelSnippets.byId(cid);

  Channel? channel;

  AdminChannelController(this.cid) {
    FirestoreService.channel.retrieve(cid).then((retrieved) {
      channel = retrieved;
      loading = false;
      notifyListeners();
    });
  }

  Future saveChannel() async {
    if (channel == null) return;
    try {
      await FirestoreService.channel.update(channel!);
      successMessage = 'Channel saved successfully!';
      errorMessage = '';
      notifyListeners();

      // Clear success message after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (successMessage.isNotEmpty) {
          successMessage = '';
          notifyListeners();
        }
      });
    } catch (error) {
      errorMessage = 'Error saving channel: ${error.toString()}';
      successMessage = '';
      notifyListeners();
    }
  }

  /// Fetches videos and playlists from the channel's YouTube URL
  /// and updates both the local channel object and Firestore
  Future<void> fetchChannelConntentFromYoutube() async {
    if (channel == null) {
      errorMessage = 'Channel data not loaded yet';
      notifyListeners();
      return;
    }

    if (channel!.channelUrl.isEmpty) {
      errorMessage = 'Channel URL is not set. Please configure the channel URL first.';
      notifyListeners();
      return;
    }

    try {
      debugPrint('AdminChannelController: Starting fetch for channel URL: ${channel!.channelUrl}');
      isFetching = true;
      errorMessage = '';
      successMessage = '';
      notifyListeners();

      // Fetch content from YouTube
      debugPrint('AdminChannelController: Calling YouTubeService.fetchChannelContent');
      final result = await YouTubeService.fetchChannelContent(channel!.channelUrl);

      final videos = result['videos'] as List? ?? [];
      final series = result['series'] as List? ?? [];

      debugPrint(
        'AdminChannelController: Fetched ${videos.length} videos and ${series.length} playlists',
      );

      // Update channel object with JSON serialization
      channel!.videos.clear();
      for (final video in videos) {
        channel!.videos[video.id] = video;
      }

      channel!.series.clear();
      for (final playlist in series) {
        channel!.series[playlist.id] = playlist;
      }

      debugPrint('AdminChannelController: Updated channel object. Persisting to Firestore...');

      // Persist changes to Firestore immediately
      await FirestoreService.channel.set(channel!, merge: true);

      debugPrint('AdminChannelController: Successfully saved to Firestore');

      successMessage =
          'Successfully fetched ${videos.length} videos and ${series.length} playlists!';
      isFetching = false;
      errorMessage = '';
      notifyListeners();

      // Clear success message after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (successMessage.isNotEmpty) {
          successMessage = '';
          notifyListeners();
        }
      });
    } catch (error) {
      debugPrint('AdminChannelController: Error during fetch: $error');
      errorMessage = 'Error fetching content: ${error.toString()}';
      isFetching = false;
      successMessage = '';
      notifyListeners();
    }
  }
}
