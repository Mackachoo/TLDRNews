import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/services/config_service.dart';

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // Get API key dynamically from Firebase Remote Config
  static String _getApiKey() => ConfigService.getYouTubeApiKey();

  /// Fetches videos and playlists from a YouTube channel URL
  /// Parses channel URL to extract channel ID (supports @handle and /channel/ID formats)
  /// Returns a map with 'videos' and 'series' (playlists) keys
  static Future<Map<String, dynamic>> fetchChannelContent(String channelUrl) async {
    try {
      debugPrint('YouTubeService.fetchChannelContent: Fetching for URL: $channelUrl');

      // Extract channel ID from URL
      var channelId = _extractChannelId(channelUrl);
      debugPrint('YouTubeService.fetchChannelContent: Extracted channel ID: $channelId');

      if (channelId.isEmpty) {
        throw 'Invalid YouTube channel URL format. Expected formats:\n'
            '- youtube.com/channel/UCxxxxxx\n'
            '- Channel ID directly (UCxxxxxx)\n'
            '- youtube.com/@handlename';
      }

      // If it looks like a handle (@...), resolve it to actual channel ID
      if (channelId.startsWith('@')) {
        debugPrint('YouTubeService.fetchChannelContent: Handle detected, resolving to channel ID');
        channelId = await _resolveChannelHandle(channelId);
        debugPrint('YouTubeService.fetchChannelContent: Resolved channel ID: $channelId');
      }

      // Fetch channel details to get uploads playlist ID
      debugPrint('YouTubeService.fetchChannelContent: Fetching channel data for ID: $channelId');
      final channelResponse = await _getChannelData(channelId);

      debugPrint(
        'YouTubeService.fetchChannelContent: Channel response items count: ${channelResponse['items']?.length ?? 0}',
      );
      debugPrint(
        'YouTubeService.fetchChannelContent: Full response: ${jsonEncode(channelResponse)}',
      );

      final uploadsPlaylistId =
          channelResponse['items']?[0]?['contentDetails']?['relatedPlaylists']?['uploads'];

      if (uploadsPlaylistId == null) {
        throw 'Could not retrieve uploads playlist for channel.\n'
            'Response structure: ${jsonEncode(channelResponse)}\n'
            'Possible causes:\n'
            '1. Invalid channel ID (Channel IDs start with UC and are 24 chars)\n'
            '2. Channel URL format not recognized\n'
            '3. YouTube API key missing or invalid\n'
            '4. YouTube API quotas exceeded';
      }

      debugPrint('YouTubeService.fetchChannelContent: Uploads playlist ID: $uploadsPlaylistId');

      // Fetch videos from uploads playlist
      debugPrint('YouTubeService.fetchChannelContent: Fetching videos from playlist');
      final videos = await _fetchPlaylistVideos(uploadsPlaylistId);
      debugPrint('YouTubeService.fetchChannelContent: Fetched ${videos.length} videos');

      // Fetch all playlists from the channel
      debugPrint('YouTubeService.fetchChannelContent: Fetching channel playlists');
      final series = await _fetchChannelPlaylists(channelId);
      debugPrint('YouTubeService.fetchChannelContent: Fetched ${series.length} playlists');

      return {'videos': videos, 'series': series};
    } catch (error) {
      debugPrint('YouTubeService.fetchChannelContent error: $error');
      rethrow;
    }
  }

  /// Extracts channel ID from various YouTube URL formats
  /// Supports:
  /// - youtube.com/@channelname (converts to channel ID via API lookup)
  /// - youtube.com/channel/UCxxxxxx
  /// - Direct channel ID (UCxxxxxx)
  static String _extractChannelId(String url) {
    try {
      // Handle direct channel ID (already extracted)
      if (url.startsWith('UC') && url.length == 24) return url;

      // Handle /channel/ format
      if (url.contains('/channel/')) {
        final id = url.split('/channel/').last.split('/').first.split('?').first;
        if (id.isNotEmpty) return id;
      }

      // Handle @handle format - return the handle for later lookup
      if (url.contains('/@')) {
        final handle = url.split('/@').last.split('/').first.split('?').first;
        if (handle.isNotEmpty) return '@$handle'; // Prefix with @ to indicate it's a handle
      }

      return '';
    } catch (error) {
      debugPrint('YouTubeService._extractChannelId error: $error');
      return '';
    }
  }

  /// Converts a YouTube channel handle (@name) to actual channel ID
  /// Makes an API call to search for the channel
  static Future<String> _resolveChannelHandle(String handle) async {
    try {
      debugPrint('YouTubeService._resolveChannelHandle: Resolving handle: $handle');

      final cleanHandle = handle.startsWith('@') ? handle.substring(1) : handle;
      final apiKey = _getApiKey();

      // Try to get channel by custom URL first
      final customUrlUri = Uri.parse(
        '$_baseUrl/search?part=snippet&type=channel&q=$cleanHandle&key=$apiKey&maxResults=1',
      );

      debugPrint(
        'YouTubeService._resolveChannelHandle: Searching for channel with handle: $cleanHandle',
      );
      final response = await http.get(customUrlUri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw 'Failed to search for channel: ${response.statusCode}';
      }

      final data = jsonDecode(response.body);
      final items = data['items'] as List?;

      if (items == null || items.isEmpty) {
        throw 'Channel handle "$cleanHandle" not found on YouTube';
      }

      final channelId = items[0]['id']?['channelId'];
      if (channelId == null) {
        throw 'Could not extract channel ID from search results';
      }

      debugPrint('YouTubeService._resolveChannelHandle: Resolved handle to channel ID: $channelId');
      return channelId;
    } catch (error) {
      debugPrint('YouTubeService._resolveChannelHandle error: $error');
      rethrow;
    }
  }

  /// Fetches channel data to retrieve uploads playlist ID
  static Future<dynamic> _getChannelData(String channelId) async {
    try {
      final apiKey = _getApiKey();
      debugPrint('YouTubeService._getChannelData: API Key present: ${apiKey.isNotEmpty}');

      final uri = Uri.parse('$_baseUrl/channels?part=contentDetails&id=$channelId&key=$apiKey');

      debugPrint('YouTubeService._getChannelData: Calling API: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      debugPrint('YouTubeService._getChannelData: Response status: ${response.statusCode}');
      debugPrint('YouTubeService._getChannelData: Response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw 'Failed to fetch channel data: ${response.statusCode}\n'
            'Error: ${errorBody['error']?['message'] ?? response.body}';
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (error) {
      debugPrint('YouTubeService._getChannelData error: $error');
      rethrow;
    }
  }

  /// Fetches all videos from a playlist
  /// Returns a list of Video objects
  static Future<List<Video>> _fetchPlaylistVideos(String playlistId, {int maxResults = 50}) async {
    try {
      final videos = <Video>[];
      String? pageToken;
      int totalFetched = 0;

      while (totalFetched < maxResults) {
        final uri = Uri.parse(
          '$_baseUrl/playlistItems?part=snippet&playlistId=$playlistId&maxResults=50&pageToken=${pageToken ?? ''}&key=${_getApiKey()}',
        );

        final response = await http.get(uri).timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw 'Failed to fetch playlist videos: ${response.statusCode}';
        }

        final data = jsonDecode(response.body);
        final items = data['items'] ?? [];

        for (final item in items) {
          if (totalFetched >= maxResults) break;

          final snippet = item['snippet'];
          final videoId = snippet?['resourceId']?['videoId'];

          if (videoId != null) {
            final video = Video(
              id: videoId,
              title: snippet?['title'] ?? 'Untitled',
              description: snippet?['description'],
              imageUrl: snippet?['thumbnails']?['high']?['url'],
              videoUrl: 'https://www.youtube.com/watch?v=$videoId',
            );
            videos.add(video);
            totalFetched++;
          }
        }

        pageToken = data['nextPageToken'];
        if (pageToken == null) break;
      }

      return videos;
    } catch (error) {
      debugPrint('YouTubeService._fetchPlaylistVideos error: $error');
      rethrow;
    }
  }

  /// Fetches all playlists from a channel
  /// Returns a list of Series objects with video IDs
  static Future<List<Series>> _fetchChannelPlaylists(
    String channelId, {
    int maxResults = 50,
  }) async {
    try {
      final series = <Series>[];
      String? pageToken;
      int totalFetched = 0;

      while (totalFetched < maxResults) {
        final uri = Uri.parse(
          '$_baseUrl/playlists?part=snippet&channelId=$channelId&maxResults=50&pageToken=${pageToken ?? ''}&key=${_getApiKey()}',
        );

        final response = await http.get(uri).timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw 'Failed to fetch channel playlists: ${response.statusCode}';
        }

        final data = jsonDecode(response.body);
        final items = data['items'] ?? [];

        for (final item in items) {
          if (totalFetched >= maxResults) break;

          final snippet = item['snippet'];
          final playlistId = item['id'];

          // Fetch videos in this playlist
          final playlistVideos = await _fetchPlaylistVideos(playlistId, maxResults: 100);
          final videoIds = playlistVideos.map((v) => v.id).toList();

          if (playlistId != null) {
            final playlist = Series(
              id: playlistId,
              title: snippet?['title'] ?? 'Untitled Playlist',
              description: snippet?['description'],
              imageUrl: snippet?['thumbnails']?['high']?['url'],
              videoIds: videoIds,
            );
            series.add(playlist);
            totalFetched++;
          }
        }

        pageToken = data['nextPageToken'];
        if (pageToken == null) break;
      }

      return series;
    } catch (error) {
      debugPrint('YouTubeService._fetchChannelPlaylists error: $error');
      rethrow;
    }
  }
}
