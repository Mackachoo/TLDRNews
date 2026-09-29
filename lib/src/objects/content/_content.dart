import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';

part '_content.g.dart';

@JsonSerializable()
/// Base for anything the app shows in a list: a title, date, description and
/// thumbnail. Extended by [Video] and [Series].
class Content {
  @JsonKey(includeToJson: false)
  /// Document id or map key, injected during deserialization.
  String id;
  String title;

  /// When the content went live; `null` if unknown.
  @TimestampConverter()
  DateTime? published;
  String? description;

  /// Thumbnail address.
  String? imageUrl;

  Content({required this.id, required this.title, this.published, this.description, this.imageUrl});

  /// Comparator ordering newest first, with undated content last.
  static int byPublishedDesc(Content a, Content b) {
    if (a.published == null) return b.published == null ? 0 : 1;
    if (b.published == null) return -1;
    return b.published!.compareTo(a.published!);
  }

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
