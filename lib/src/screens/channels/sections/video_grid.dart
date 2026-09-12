import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/channels/widgets/video_widget.dart';
import 'package:tldrnews_app/src/widgets/responsive_grid.dart';

/// Videos arrive one block at a time, the next pulled in as the end nears.
class VideoGrid extends StatefulWidget {
  const VideoGrid(this.ctlr, {super.key});

  final ChannelController ctlr;

  @override
  State<VideoGrid> createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  static const double _trigger = 400;

  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport());
  }

  @override
  void dispose() {
    scroll.removeListener(_onScroll);
    scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scroll.position.extentAfter < _trigger) _loadMore();
  }

  /// A first block shorter than the screen never scrolls, so it cannot pull in
  /// the next one on its own.
  void _fillViewport() {
    if (!mounted || !scroll.hasClients) return;
    if (scroll.position.maxScrollExtent == 0 && widget.ctlr.hasMore) _loadMore();
  }

  Future<void> _loadMore() async {
    await widget.ctlr.loadMoreVideos();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minItemWidth: 200,
      maxCrossAxisCount: 4,
      controller: scroll,
      footer: widget.ctlr.loadingMore
          ? const Padding(padding: .all(16), child: CircularProgressIndicator())
          : null,
      children: widget.ctlr.videos.map((video) => VideoWidget(video)).toList(),
    );
  }
}
