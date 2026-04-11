import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';

part 'youtube_video.g.dart';

@JsonSerializable()
class YoutubeVideo extends Video {
  @JsonKey(includeToJson: false)
  String? overrideUrl;

  YoutubeVideo({
    required super.id,
    required super.title,
    super.published,
    super.description,
    super.imageUrl,
    this.overrideUrl,
  });

  @override
  @JsonKey(includeFromJson: false)
  String get videoUrl => overrideUrl ?? 'https://www.youtube.com/watch?v=$id';

  @override
  Map<String, dynamic> toJson() => _$YoutubeVideoToJson(this);
  factory YoutubeVideo.fromJson(Map<String, dynamic> json) => _$YoutubeVideoFromJson(json);
}
