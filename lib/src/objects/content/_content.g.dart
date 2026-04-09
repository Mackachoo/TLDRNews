// GENERATED CODE - DO NOT MODIFY BY HAND

part of '_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
