import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';

part 'youtube_video.g.dart';

@JsonSerializable()
/// A [Video] hosted on YouTube, whose [id] is the YouTube video id.
class YoutubeVideo extends Video {
  @JsonKey(includeToJson: false)
  /// Address to use instead of the YouTube watch page, if an admin set one.
  String? overrideUrl;

  YoutubeVideo({
    required super.id,
    required super.title,
    super.published,
    super.description,
    super.imageUrl,
    this.overrideUrl,
  });

  /// [overrideUrl] if set, otherwise the standard YouTube watch link for [id].
  @override
  @JsonKey(includeFromJson: false)
  String get videoUrl => overrideUrl ?? 'https://www.youtube.com/watch?v=$id';

  /// Copy safe to edit without touching a cached instance.
  YoutubeVideo copy() => YoutubeVideo(
    id: id,
    title: title,
    published: published,
    description: description,
    imageUrl: imageUrl,
    overrideUrl: overrideUrl,
  );

  @override
  Map<String, dynamic> toJson() => _$YoutubeVideoToJson(this);
  factory YoutubeVideo.fromJson(Map<String, dynamic> json) => _$YoutubeVideoFromJson(json);
}
