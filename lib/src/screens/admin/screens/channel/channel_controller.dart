import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

class AdminChannelController extends ChangeNotifier {
  bool loading = true;

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
}
