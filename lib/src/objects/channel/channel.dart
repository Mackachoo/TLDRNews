import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends ChannelSnippet {
  Channel({
    required super.id,
    required super.name,
    required this.description,
    Map<String, Video>? videos,
    Map<String, Series>? series,
  }) : videos = videos ?? {},
       series = series ?? {};

  final String description;

  final Map<String, Video> videos;
  final Map<String, Series> series;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}
