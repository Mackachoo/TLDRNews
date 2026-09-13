import 'package:cloud_functions/cloud_functions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

/// Callable Cloud Functions. Only the backend holds the YouTube API key, so all
/// ingestion goes through here.
class FunctionsService {
  static const String region = 'europe-west1';

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: region);

  //* Youtube Ingest ---------------------------------------------------

  /// Pulls new videos and playlists into the channel's blocks. [rebuild] wipes
  /// the blocks and re-downloads the full history instead.
  static Future<Json?> syncChannel(String cid, {bool rebuild = false}) => _call('sync_channel', {
    'cid': cid,
    'action': 'sync',
    'mode': rebuild ? 'rebuild' : 'incremental',
  });

  static Future<YoutubeVideo?> resolveVideo(String url) async {
    final data = await _call('sync_channel', {'action': 'resolve_video', 'url': url});
    return data == null ? null : YoutubeVideo.fromJson(data);
  }

  static Future<Series?> resolveSeries(String url) async {
    final data = await _call('sync_channel', {'action': 'resolve_series', 'url': url});
    return data == null ? null : Series.fromJson(data);
  }

  // *. Party Approval -------------------------------------------------

  static Future<Json?> requestVideoForApproval() async {
    return await _call('request_party_video_for_approval');
  }

  static Future<Json?> approvePartyVideo(String videoUrl, String hash) async {
    return await _call('approve_party_video', {'url': videoUrl, 'hash': hash});
  }

  //* Private Methods --------------------------------------------------

  static Future<Json?> _call(String name, [Json payload = const {}]) async {
    try {
      final result = await _functions.httpsCallable(name).call<Object?>(payload);
      return Json.from(result.data as Map);
    } on FirebaseFunctionsException catch (error) {
      debugPrint('FunctionsService.$name: ${error.code} ${error.message}');
      return null;
    } catch (error) {
      debugPrint('FunctionsService.$name: $error');
      return null;
    }
  }
}
