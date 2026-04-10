// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  uid: json['uid'] as String,
  name: json['name'] as String?,
  analyticsConsent: json['analyticsConsent'] as bool? ?? false,
  marketingConsent: json['marketingConsent'] as bool? ?? false,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'analyticsConsent': instance.analyticsConsent,
  'marketingConsent': instance.marketingConsent,
};
