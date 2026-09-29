import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/services/firestore/converters.dart';

part 'meta.g.dart';

@JsonSerializable()
/// Server-managed permissions for a user, stored at `meta/{uid}`.
///
/// Kept apart from [Account] so the user cannot grant themselves anything.
class Meta {
  Meta({this.admin = false, this.party});

  /// Whether the user may open the admin screens and edit channels.
  final bool admin;

  /// When the user last had TLDR Party membership approved, or `null` if never.
  @DateTimeConverter()
  final DateTime? party;

  /// Membership is [PartyState.member] for 90 days after [party], then
  /// [PartyState.expiredMember] until re-approved.
  PartyState get partyState {
    if (party == null) return PartyState.nonMember;
    final difference = DateTime.now().difference(party!);
    final test = difference.inDays;
    return difference.inDays <= 90 ? PartyState.member : PartyState.expiredMember;
  }

  /// Channels this user can open: the free ones, preceded by TLDR Party for
  /// current members.
  List<ChannelSnippet> get channels {
    List<ChannelSnippet> channels = [];
    if (partyState == PartyState.member) channels.add(ChannelSnippets.party);
    channels.addAll(ChannelSnippets.free);
    return channels;
  }

  Map<String, dynamic> toJson() => _$MetaToJson(this);
  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

/// A user's standing with the members-only TLDR Party channel.
enum PartyState { member, nonMember, expiredMember }
