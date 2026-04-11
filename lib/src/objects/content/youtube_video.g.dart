// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YoutubeVideo _$YoutubeVideoFromJson(Map<String, dynamic> json) => YoutubeVideo(
  id: json['id'] as String,
  title: json['title'] as String,
  published: json['published'] == null
      ? null
      : DateTime.parse(json['published'] as String),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  overrideUrl: json['overrideUrl'] as String?,
);

Map<String, dynamic> _$YoutubeVideoToJson(YoutubeVideo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'published': instance.published?.toIso8601String(),
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };
