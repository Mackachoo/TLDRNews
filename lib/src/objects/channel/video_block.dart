import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';

/// One page of a channel's videos, stored at `channels/{cid}/videos/{id}`.
///
/// The document id is the block's start boundary: a video belongs to the block
/// with the greatest [startAt] at or before its published date. Every other
/// stored field is derived from [videos], so the map is the only source of truth.
class VideoBlock {
  VideoBlock({required this.startAt, Map<String, YoutubeVideo>? videos})
    : videos = videos ?? {};

  final DateTime startAt;
  final Map<String, YoutubeVideo> videos;

  String get id => formatId(startAt);
  int get count => videos.length;

  List<YoutubeVideo> get sorted => videos.values.toList()..sort(Content.byPublishedDesc);

  static String formatId(DateTime moment) {
    String two(int value) => value.toString().padLeft(2, '0');
    final utc = moment.toUtc();
    return '${utc.year}${two(utc.month)}${two(utc.day)}T'
        '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }

  VideoBlock copy() =>
      VideoBlock(startAt: startAt, videos: videos.map((k, v) => MapEntry(k, v.copy())));

  Map<String, dynamic> toJson() {
    final published = videos.values.map((video) => video.published).nonNulls.toList()..sort();
    return {
      'startAt': Timestamp.fromDate(startAt),
      'oldest': Timestamp.fromDate(published.firstOrNull ?? startAt),
      'newest': Timestamp.fromDate(published.lastOrNull ?? startAt),
      'count': videos.length,
      'videoIds': videos.keys.toList()..sort(),
      'videos': videos.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}
