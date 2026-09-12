import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/services/firestore/converters.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
  Meta({this.admin = false, this.party});

  final bool admin;

  @DateTimeConverter()
  final DateTime? party;

  // If the user has approved TLDR Party membership within the last 90 days, include the TLDR Party channel.
  bool get partyApproved {
    if (party == null) return false;
    final difference = DateTime.now().difference(party!);
    final test = difference.inDays;
    return difference.inDays <= 90;
  }

  List<ChannelSnippet> get channels {
    List<ChannelSnippet> channels = [];
    if (partyApproved) channels.add(ChannelSnippets.party);
    channels.addAll(ChannelSnippets.free);
    return channels;
  }

  Map<String, dynamic> toJson() => _$MetaToJson(this);
  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}
