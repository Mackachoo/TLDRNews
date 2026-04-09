// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  videos: (json['videos'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, Video.fromJson(e as Map<String, dynamic>)),
  ),
  series: (json['series'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, Series.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'videos': instance.videos,
  'series': instance.series,
};
