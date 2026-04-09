import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/channel/channel.dart';
import 'package:tldrnews_app/src/services/firestore/_firestore_core.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class ChannelService extends FirestoreCore {
  @override
  Duration get cacheAge => const Duration(minutes: 15);

  //* CRUD -------------------------------------------------------------

  Future<Channel?> retrieve(String channelId, {bool useCache = true}) async {
    try {
      Channel? channel = useCache ? checkCached<Channel>(channelId) : null;
      if (channel == null) {
        DocumentSnapshot channelDoc = await channels.doc(channelId).get();
        if (!channelDoc.exists) throw 'Channel not found';

        final data = channelDoc.data() as Json;
        data['id'] = channelDoc.id;
        channel = Channel.fromJson(data);
        insertCached<Channel>(channelId, channel);
      }
      return channel;
    } catch (error) {
      debugPrint('ChannelService.retrieve: $error');
      return null;
    }
  }

  Future<bool?> update(Channel updates) async {
    Channel? channel = await retrieve(updates.id, useCache: false);
    if (channel == null) return null;

    try {
      await channels.doc(updates.id).update(updates.toJson());
      updateCached<Channel>(updates.id, updates);
      debugPrint('Channel:\t${updates.id} updated');
      return true;
    } catch (error) {
      debugPrint('ChannelService.update: $error');
      return false;
    }
  }

  Future<bool?> set(Channel updates, {bool merge = false}) async {
    try {
      await channels.doc(updates.id).set(updates.toJson(), SetOptions(merge: merge));
      updateCached<Channel>(updates.id, updates);
      debugPrint('Channel:\t${updates.id} set');
      return true;
    } catch (error) {
      debugPrint('ChannelService.set: $error');
      return false;
    }
  }

  Future<bool> delete(String channelId) async {
    try {
      await channels.doc(channelId).delete();
      debugPrint('Channel:\t$channelId deleted');
      clearCached<Channel>(channelId);
      return true;
    } catch (error) {
      debugPrint('ChannelService.delete: $error');
      return false;
    }
  }
}
