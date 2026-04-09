import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreCore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @protected
  CollectionReference get accounts => firestore.collection('accounts');

  @protected
  CollectionReference get channels => firestore.collection('channels');

  // * Caching System ---------------------------------------------------

  @protected
  Duration get cacheAge => Duration(minutes: 10);

  @protected
  final Map<String, (Object?, DateTime)> cache = {};

  @protected
  String _genCacheKey<T>(String id) => '$id:${T.toString()}';

  @protected
  void insertCached<T>(String id, T? object) {
    final key = _genCacheKey<T>(id);
    cache[key] = (object, DateTime.now());
  }

  @protected
  T? checkCached<T>(String id) {
    final key = _genCacheKey<T>(id);
    if (cache.containsKey(key)) {
      final (cachedObject, cachedTime) = cache[key]!;
      if (DateTime.now().difference(cachedTime) < cacheAge) {
        return cachedObject as T;
      }
    }
    return null;
  }

  @protected
  void updateCached<T>(String id, T? object) {
    final key = _genCacheKey<T>(id);
    if (cache.containsKey(key)) {
      final oldTime = cache[key]?.$2;
      cache[key] = (object, oldTime ?? DateTime.now());
    }
  }

  @protected
  void clearCached<T>(String id) {
    final key = _genCacheKey<T>(id);
    cache.remove(key);
  }
}
