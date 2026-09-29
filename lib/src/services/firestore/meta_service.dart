import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tldrnews_app/src/objects/account/meta.dart';
import 'package:tldrnews_app/src/services/firestore/_firestore_core.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

/// Reads and writes `meta/{uid}` permission documents.
class MetaService extends FirestoreCore {
  //* CRUD -------------------------------------------------------------

  /// The [Meta] for [uid], or `null` if missing.
  Future<Meta?> retrieve(String uid) async {
    try {
      DocumentSnapshot metaDoc = await meta.doc(uid).get();
      if (!metaDoc.exists) throw 'Meta not found';

      final data = metaDoc.data() as Json;
      data['uid'] = uid;
      return Meta.fromJson(data);
    } catch (error) {
      debugPrint('MetaService.retrieve: $error');
      return null;
    }
  }

  /// All [Meta] documents whose [key] equals [value], keyed by uid. Rethrows on
  /// failure.
  Future<Map<String, Meta>> retrieveBy(String key, Object? value) async {
    try {
      QuerySnapshot metaQuery = await meta.where(key, isEqualTo: value).get();
      return Map.fromEntries(
        metaQuery.docs.map((doc) {
          final data = doc.data() as Json;
          data['uid'] = doc.id;
          final meta = Meta.fromJson(data);
          return MapEntry(doc.id, meta);
        }),
      );
    } catch (error) {
      debugPrint('MetaService.retrieveAll: $error');
      rethrow;
    }
  }

  /// Merges a single [key]/[value] pair into [uid]'s document. Rethrows on
  /// failure.
  Future<void> set(String uid, {required String key, Object? value}) async {
    try {
      await meta.doc(uid).set({key: value}, SetOptions(merge: true));
    } catch (error) {
      debugPrint('MetaService.set: $error');
      rethrow;
    }
  }
}
