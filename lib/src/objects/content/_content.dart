import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/timestamp_converter.dart';

part '_content.g.dart';

@JsonSerializable()
class Content {
  @JsonKey(includeToJson: false)
  String id;
  String title;
  @TimestampConverter()
  DateTime? published;
  String? description;
  String? imageUrl;

  Content({required this.id, required this.title, this.published, this.description, this.imageUrl});

  /// Newest first, undated last.
  static int byPublishedDesc(Content a, Content b) {
    if (a.published == null) return b.published == null ? 0 : 1;
    if (b.published == null) return -1;
    return b.published!.compareTo(a.published!);
  }

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
