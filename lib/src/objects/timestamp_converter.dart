import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore hands back a [Timestamp]; older documents may still hold an ISO
/// string, so reads accept both.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) => switch (json) {
    Timestamp timestamp => timestamp.toDate(),
    String text => DateTime.tryParse(text),
    _ => null,
  };

  @override
  Object? toJson(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
}
