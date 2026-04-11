// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  title: json['title'] as String,
  published: json['published'] == null
      ? null
      : DateTime.parse(json['published'] as String),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'title': instance.title,
  'published': instance.published?.toIso8601String(),
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
