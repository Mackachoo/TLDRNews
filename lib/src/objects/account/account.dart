import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

/// A user's profile and consent choices, stored at `accounts/{uid}`.
///
/// Permissions live in [Meta], not here, because users may edit their own account.
@JsonSerializable()
class Account {
  /// Firebase Auth user id, also the document id.
  final String uid;
  final String? name;
  final String? email;

  /// Whether the user agreed to analytics.
  final bool analyticsConsent;

  /// Whether the user agreed to marketing communications.
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
