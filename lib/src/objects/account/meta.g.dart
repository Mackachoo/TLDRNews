// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  admin: json['admin'] as bool? ?? false,
  party: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['party'],
    const DateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'admin': instance.admin,
  'party': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.party,
    const DateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
