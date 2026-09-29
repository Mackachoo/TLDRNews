import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Base for the Firestore services: collection references plus a small
/// in-memory cache keyed by id and type.
///
/// Entries expire after [cacheAge]. Cached objects are shared, so callers that
/// mutate one must copy it first.
class FirestoreCore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @protected
  CollectionReference get meta => firestore.collection('meta');
  @protected
  CollectionReference get accounts => firestore.collection('accounts');
  @protected
  CollectionReference get channels => firestore.collection('channels');
  @protected
  CollectionReference videoBlocks(String cid) => channels.doc(cid).collection('videos');

  // * Caching System ---------------------------------------------------

  @protected
  /// How long a cached entry stays valid. Override per service.
  Duration get cacheAge => Duration(minutes: 10);

  @protected
  final Map<String, (Object?, DateTime)> cache = {};

  @protected
  String _genCacheKey<T>(String id) => '$id:${T.toString()}';

  @protected
  /// Stores [object] under [id] for type `T`, restarting its expiry.
  void insertCached<T>(String id, T? object) {
    final key = _genCacheKey<T>(id);
    cache[key] = (object, DateTime.now());
  }

  @protected
  /// The unexpired cached `T` for [id], or `null`.
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
  /// Replaces an existing entry without extending its expiry. Does nothing if
  /// [id] is not cached.
  void updateCached<T>(String id, T? object) {
    final key = _genCacheKey<T>(id);
    if (cache.containsKey(key)) {
      final oldTime = cache[key]?.$2;
      cache[key] = (object, oldTime ?? DateTime.now());
    }
  }

  @protected
  /// Drops the cached `T` for [id].
  void clearCached<T>(String id) {
    final key = _genCacheKey<T>(id);
    cache.remove(key);
  }
}
