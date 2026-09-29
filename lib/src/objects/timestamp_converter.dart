import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between Firestore [Timestamp]s and [DateTime]s for model fields.
///
/// Firestore hands back a [Timestamp]; older documents may still hold an ISO
/// string, so reads accept both. Anything else reads as `null`. Writes always
/// produce a [Timestamp], never a string.
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
