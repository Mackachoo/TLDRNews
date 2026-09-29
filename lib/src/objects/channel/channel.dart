import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';

part 'channel.g.dart';

/// A channel's full document at `channels/{cid}`: its details and series.
///
/// Videos are not held here; they are paged in as [VideoBlock]s. Only the Cloud
/// Function writes to channels, apart from admin edits.
@JsonSerializable()
class Channel extends ChannelSnippet {
  Channel({
    required super.id,
    required super.name,
    required this.channelUrl,
    this.description,
    Map<String, Series>? series,
  }) : series = series ?? {};

  /// Link to the channel on YouTube.
  final String channelUrl;
  final String? description;

  /// Playlists shown for this channel, keyed by series id.
  final Map<String, Series> series;

  /// Deep copy. Callers that mutate a [Channel] must work on one of these —
  /// [ChannelService] hands out a shared cached instance.
  Channel copy() => Channel(
    id: id,
    name: name,
    channelUrl: channelUrl,
    description: description,
    series: series.map((k, v) => MapEntry(k, v.copy())),
  );

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);

  /// Serialises with each [Series] converted explicitly, since the generated
  /// code would leave the map values as objects.
  Map<String, dynamic> toJson() {
    final json = _$ChannelToJson(this);
    json['series'] = series.map((k, v) => MapEntry(k, v.toJson()));
    return json;
  }
}
