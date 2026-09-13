import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/video_block.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';
import 'package:tldrnews_app/src/services/firestore/_firestore_core.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class ChannelService extends FirestoreCore {
  @override
  Duration get cacheAge => const Duration(minutes: 15);

  //* CRUD -------------------------------------------------------------

  Future<Channel?> retrieve(String cid, {bool useCache = true}) async {
    try {
      Channel? channel = useCache ? checkCached<Channel>(cid) : null;
      if (channel == null) {
        DocumentSnapshot channelDoc = await channels.doc(cid).get();
        if (!channelDoc.exists) throw 'Channel not found';

        final data = channelDoc.data() as Json;

        // Manually deserialize series with error handling
        final Map<String, Series> series = {};
        if (data['series'] is Map) {
          for (final entry in (data['series'] as Map).entries) {
            try {
              final seriesJson = Map<String, dynamic>.from(entry.value as Map);
              seriesJson['id'] = entry.key;
              series[entry.key] = Series.fromJson(seriesJson);
            } catch (e) {
              debugPrint('ChannelService.retrieve: Skipping malformed series ${entry.key}: $e');
            }
          }
        }

        channel = Channel(
          id: cid,
          name: data['name'] as String? ?? 'Unknown',
          channelUrl: data['channelUrl'] as String? ?? '',
          description: data['description'] as String?,
          series: series,
        );

        insertCached<Channel>(cid, channel);
      }
      return channel;
    } catch (error) {
      debugPrint('ChannelService.retrieve: $error');
      return null;
    }
  }

  Future<bool?> update(Channel updates) async {
    Channel? channel = await retrieve(updates.id, useCache: false);
    if (channel == null) return null;

    try {
      await channels.doc(updates.id).update(updates.toJson());
      updateCached<Channel>(updates.id, updates.copy());
      debugPrint('Channel:\t${updates.id} updated');
      return true;
    } catch (error) {
      debugPrint('ChannelService.update: $error');
      return false;
    }
  }

  Future<bool?> set(Channel updates, {bool merge = false}) async {
    try {
      await channels.doc(updates.id).set(updates.toJson(), SetOptions(merge: merge));
      updateCached<Channel>(updates.id, updates.copy());
      debugPrint('Channel:\t${updates.id} set');
      return true;
    } catch (error) {
      debugPrint('ChannelService.set: $error');
      return false;
    }
  }

  Future<bool> delete(String channelId) async {
    try {
      await channels.doc(channelId).delete();
      debugPrint('Channel:\t$channelId deleted');
      clearCached<Channel>(channelId);
      return true;
    } catch (error) {
      debugPrint('ChannelService.delete: $error');
      return false;
    }
  }

  //* Video Blocks -----------------------------------------------------

  Future<VideoBlock?> newestVideoBlock(String cid) =>
      _firstBlock(videoBlocks(cid).orderBy('startAt', descending: true).limit(1), 'newest');

  /// The block immediately older than [before], which is a block's own startAt.
  Future<VideoBlock?> olderVideoBlock(String cid, DateTime before) => _firstBlock(
    videoBlocks(cid)
        .where('startAt', isLessThan: Timestamp.fromDate(before))
        .orderBy('startAt', descending: true)
        .limit(1),
    'older',
  );

  /// Finds the block in [cid] holding [videoId], for links that arrive before
  /// the containing block has been paged in.
  Future<VideoBlock?> blockContainingVideo(String cid, String videoId) async {
    try {
      final snapshot = await videoBlocks(
        cid,
      ).where('videoIds', arrayContains: videoId).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      return _deserialize(snapshot.docs.first);
    } catch (error) {
      debugPrint('ChannelService.blockContainingVideo: $error');
      return null;
    }
  }

  Future<bool> setVideoBlock(String cid, VideoBlock block) async {
    try {
      await videoBlocks(cid).doc(block.id).set(block.toJson());
      debugPrint('VideoBlock:\t$cid/${block.id} set');
      return true;
    } catch (error) {
      debugPrint('ChannelService.setVideoBlock: $error');
      return false;
    }
  }

  //* Private Methods --------------------------------------------------

  Future<VideoBlock?> _firstBlock(Query query, String caller) async {
    try {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return null;
      return _deserialize(snapshot.docs.first);
    } catch (error) {
      debugPrint('ChannelService.${caller}VideoBlock: $error');
      return null;
    }
  }

  VideoBlock? _deserialize(DocumentSnapshot doc) {
    final data = doc.data() as Json?;
    final startAt = const TimestampConverter().fromJson(data?['startAt']);
    if (startAt == null) return null;

    final Map<String, YoutubeVideo> videos = {};
    if (data?['videos'] is Map) {
      for (final entry in (data!['videos'] as Map).entries) {
        try {
          final videoJson = Map<String, dynamic>.from(entry.value as Map);
          videoJson['id'] = entry.key;
          videos[entry.key] = YoutubeVideo.fromJson(videoJson);
        } catch (e) {
          debugPrint('ChannelService: Skipping malformed video ${entry.key}: $e');
        }
      }
    }

    return VideoBlock(startAt: startAt, videos: videos);
  }
}
