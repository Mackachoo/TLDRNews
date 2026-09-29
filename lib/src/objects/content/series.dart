import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';

part 'series.g.dart';

@JsonSerializable()
/// A playlist of videos within a channel, stored in the channel's `series` map.
class Series extends Content {
  @JsonKey(includeToJson: false)
  /// Ids of the videos in the playlist, in playlist order.
  List<String> videoIds;

  Series({
    required super.id,
    required super.title,
    super.published,
    super.description,
    super.imageUrl,
    this.videoIds = const [],
  });

  /// Deep copy with its own [videoIds] list.
  Series copy() => Series(
    id: id,
    title: title,
    published: published,
    description: description,
    imageUrl: imageUrl,
    videoIds: List.of(videoIds),
  );

  @override
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}
