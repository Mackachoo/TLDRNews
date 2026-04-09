// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
