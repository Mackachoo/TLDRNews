import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/_content.dart';

part 'video.g.dart';

@JsonSerializable()
class Video extends Content {
  @JsonKey(includeToJson: false)
  String? videoUrl;

  Video({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    this.videoUrl,
  });

  String get youtubeUrl => videoUrl ?? 'https://www.youtube.com/watch?v=$id';

  @override
  Map<String, dynamic> toJson() => _$VideoToJson(this);
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}
