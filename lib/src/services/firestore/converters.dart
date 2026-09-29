import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts a required Firestore [Timestamp] to a [DateTime].
class DateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

/// Nullable counterpart of [DateTimeConverter].
class DateTimeNullableConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeNullableConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();
  @override
  Timestamp? toJson(DateTime? dateTime) => dateTime != null ? Timestamp.fromDate(dateTime) : null;
}
