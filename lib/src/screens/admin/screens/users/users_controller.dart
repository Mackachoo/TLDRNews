import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/account/account.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/utils/message.dart';

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

  Future addAdmin(BuildContext context, String email) async {
    try {
      final uid = await FirestoreService.account.find(email);
      if (uid == null) throw 'No account found with that email';
      if (admins != null && admins!.any((admin) => admin?.uid == uid)) {
        throw 'That user is already an admin';
      }

      await FirestoreService.meta.set(uid, key: 'admin', value: true);
      final account = await FirestoreService.account.retrieve(uid);
      if (account != null) {
        admins ??= [];
        admins!.add(account);
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) Message.error(context, e);
    }
  }

  Future removeAdmin(BuildContext context, String uid) async {
    try {
      await FirestoreService.meta.set(uid, key: 'admin', value: false);
      if (admins != null) {
        admins!.removeWhere((admin) => admin?.uid == uid);
        notifyListeners();
      }
      if (context.mounted) Message.info(context, 'Admin removed successfully');
    } catch (e) {
      if (context.mounted) Message.error(context, e);
    }
  }
}
