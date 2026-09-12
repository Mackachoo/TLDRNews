import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends ChannelSnippet {
  Channel({
    required super.id,
    required super.name,
    required this.channelUrl,
    this.description,
    Map<String, Series>? series,
  }) : series = series ?? {};

  final String channelUrl;
  final String? description;

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

  Map<String, dynamic> toJson() {
    final json = _$ChannelToJson(this);
    json['series'] = series.map((k, v) => MapEntry(k, v.toJson()));
    return json;
  }
}
