import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/account/account.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';

class AdminUsersController extends ChangeNotifier {
  bool loading = true;
  List<Account?>? admins;

  AdminUsersController() {
    FirestoreService.meta.retrieveBy('admin', true).then((admin) async {
      List<String> uids = admin.keys.toList();
      admins = (await Future.wait(
        uids.map((uid) => FirestoreService.account.retrieve(uid)),
      )).whereType<Account>().toList();
      loading = false;
      notifyListeners();
    });
  }
}
