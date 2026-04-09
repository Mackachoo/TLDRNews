import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';

part 'series.g.dart';

@JsonSerializable()
class Series extends Content {
  @JsonKey(includeToJson: false)
  List<String> videoIds;

  Series({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    this.videoIds = const [],
  });

  @override
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}
