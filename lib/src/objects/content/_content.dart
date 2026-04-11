import 'package:json_annotation/json_annotation.dart';

part '_content.g.dart';

@JsonSerializable()
class Content {
  @JsonKey(includeToJson: false)
  String id;
  String title;
  DateTime? published;
  String? description;
  String? imageUrl;

  Content({required this.id, required this.title, this.published, this.description, this.imageUrl});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
