import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tldrnews_app/src/objects/account/account.dart';
import 'package:tldrnews_app/src/services/firestore/_firestore_core.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class AccountService extends FirestoreCore {
  //* CRUD -------------------------------------------------------------

  Stream<Account?> stream(String uid) {
    return accounts
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;

          final data = snapshot.data() as Json;
          data['uid'] = uid;
          return Account.fromJson(data);
        })
        .handleError((error) {
          debugPrint('AccountService.stream error: $error');
          return null;
        });
  }

  Future<Account?> retrieve(String uid) async => stream(uid).first;

  Future<bool> update(Account account) async {
    try {
      await accounts.doc(account.uid).update(account.toJson());
      return true;
    } catch (error) {
      debugPrint('AccountService.update: $error');
      return false;
    }
  }

  Future<bool> set(Account account, {bool merge = false}) async {
    try {
      await accounts.doc(account.uid).set(account.toJson(), SetOptions(merge: merge));
      return true;
    } catch (error) {
      debugPrint('AccountService.set: $error');
      return false;
    }
  }

  Future<bool> exists(String uid) async {
    final doc = await accounts.doc(uid).get();
    return doc.exists;
  }

  // This will only work for admins as only they can read other accounts
  Future<String?> find(String email) async {
    try {
      final query = await accounts.where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isEmpty) return null;
      return query.docs.first.id;
    } catch (error) {
      debugPrint('AccountService.find: $error');
      rethrow;
    }
  }
}
