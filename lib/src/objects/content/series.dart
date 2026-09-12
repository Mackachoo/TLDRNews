import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';

part 'series.g.dart';

@JsonSerializable()
class Series extends Content {
  @JsonKey(includeToJson: false)
  List<String> videoIds;

  Series({
    required super.id,
    required super.title,
    super.published,
    super.description,
    super.imageUrl,
    this.videoIds = const [],
  });

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
