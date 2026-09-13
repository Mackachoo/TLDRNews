import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

class DateTimeNullableConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeNullableConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();
  @override
  Timestamp? toJson(DateTime? dateTime) => dateTime != null ? Timestamp.fromDate(dateTime) : null;
}
