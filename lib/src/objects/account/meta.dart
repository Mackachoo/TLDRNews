import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
  final bool admin;
  final bool party;

  Meta({this.admin = false, this.party = false});

  Map<String, dynamic> toJson() => _$MetaToJson(this);
  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}
