import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

class ChannelController extends ChangeNotifier {
  bool loading = true;
  final ChannelSnippet snippet;
  Channel? channel;

  ChannelController(this.snippet) {
    FirestoreService.channel.retrieve(snippet.id).then((value) async {
      loading = false;
      channel = value;
      notifyListeners();
    });
  }
}
