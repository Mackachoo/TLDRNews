import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/video_block.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

/// Walks a channel's video blocks newest first, one block per request.
mixin VideoPaging on ChangeNotifier {
  String get cid;

  final List<VideoBlock> blocks = [];
  final List<YoutubeVideo> videos = [];

  bool loadingMore = false;
  bool hasMore = true;

  Future<void> loadNewestBlock() async =>
      _append(await FirestoreService.channel.newestVideoBlock(cid));

  Future<void> loadMoreVideos() async {
    if (loadingMore || !hasMore || blocks.isEmpty) return;

    loadingMore = true;
    notifyListeners();

    _append(await FirestoreService.channel.olderVideoBlock(cid, blocks.last.startAt));

    loadingMore = false;
    notifyListeners();
  }

  void resetPaging() {
    blocks.clear();
    videos.clear();
    hasMore = true;
  }

  @protected
  void rebuildVideos() => videos
    ..clear()
    ..addAll(blocks.expand((block) => block.sorted));

  void _append(VideoBlock? block) {
    if (block == null) {
      hasMore = false;
      return;
    }
    blocks.add(block);
    videos.addAll(block.sorted);
  }
}
