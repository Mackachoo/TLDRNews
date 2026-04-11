import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String uid;
  final String? name;
  final String? email;

  // Consent
  final bool analyticsConsent;
  final bool marketingConsent;

  Account({
    required this.uid,
    this.name,
    this.email,
    this.analyticsConsent = false,
    this.marketingConsent = false,
  });

  Map<String, dynamic> toJson() => _$AccountToJson(this);
  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}
