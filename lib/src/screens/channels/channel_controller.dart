import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/screens/channels/video_paging.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

class ChannelController extends ChangeNotifier with VideoPaging {
  bool loading = true;
  final ChannelSnippet snippet;
  Channel? channel;

  @override
  String get cid => snippet.id;

  ChannelController(this.snippet) {
    _load();
  }

  Future<void> _load() async {
    channel = await FirestoreService.channel.retrieve(cid);
    await loadNewestBlock();
    loading = false;
    notifyListeners();
  }
}
