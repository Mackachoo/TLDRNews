import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/video_block.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

/// Walks a channel's video blocks newest first, one block per request.
///
/// Mix into a [ChangeNotifier] that supplies [cid]. [videos] is the flattened,
/// newest-first list of everything loaded so far, for driving a grid.
mixin VideoPaging on ChangeNotifier {
  /// Id of the channel being paged.
  String get cid;

  /// Blocks loaded so far, newest first.
  final List<VideoBlock> blocks = [];

  /// Videos from [blocks], newest first.
  final List<YoutubeVideo> videos = [];

  /// True while [loadMoreVideos] is fetching.
  bool loadingMore = false;

  /// False once the oldest block has been reached.
  bool hasMore = true;

  /// Loads the first page. Call once, after construction or [resetPaging].
  Future<void> loadNewestBlock() async =>
      _append(await FirestoreService.channel.newestVideoBlock(cid));

  /// Loads the next older block. Does nothing while loading, when exhausted, or
  /// before the first block.
  Future<void> loadMoreVideos() async {
    if (loadingMore || !hasMore || blocks.isEmpty) return;

    loadingMore = true;
    notifyListeners();

    _append(await FirestoreService.channel.olderVideoBlock(cid, blocks.last.startAt));

    loadingMore = false;
    notifyListeners();
  }

  /// Forgets everything loaded so paging can restart from the newest block.
  void resetPaging() {
    blocks.clear();
    videos.clear();
    hasMore = true;
  }

  /// Recomputes [videos] from [blocks] after a block has been edited.
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
