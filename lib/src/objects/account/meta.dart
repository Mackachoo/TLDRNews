import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
  final bool admin;
  final bool party;

  Meta({this.admin = false, this.party = false});

  List<ChannelSnippet> get channels {
    List<ChannelSnippet> channels = [];
    // if (party) channels.add(ChannelSnippets.party);
    channels.addAll(ChannelSnippets.free);
    return channels;
  }

  Map<String, dynamic> toJson() => _$MetaToJson(this);
  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}
