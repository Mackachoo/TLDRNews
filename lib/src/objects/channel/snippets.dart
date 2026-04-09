import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/channel_icon.dart';

part 'snippets.g.dart';

@JsonSerializable()
class ChannelSnippet {
  @JsonKey(includeToJson: false)
  final String id;
  final String name;
  ChannelIcon get icon => ChannelIcon.fromId(id);

  ChannelSnippet({required this.id, required this.name});
}

class ChannelSnippets {
  static ChannelSnippet get uk => ChannelSnippet(id: 'uk', name: 'TLDR UK');
  static ChannelSnippet get global => ChannelSnippet(id: 'global', name: 'TLDR Global');
  static ChannelSnippet get eu => ChannelSnippet(id: 'eu', name: 'TLDR EU');
  static ChannelSnippet get business => ChannelSnippet(id: 'business', name: 'TLDR Business');
  static ChannelSnippet get podcasts => ChannelSnippet(id: 'podcasts', name: 'TLDR Podcasts');
  static ChannelSnippet get party => ChannelSnippet(id: 'party', name: 'TLDR Party');

  static ChannelSnippet? byId(String id) => all.firstWhereOrNull((channel) => channel.id == id);

  static List<ChannelSnippet> get all => [party, uk, global, eu, business, podcasts];
  static List<IconButton> buttons(BuildContext context, [String? active]) {
    final channels = ChannelSnippets.all;
    return channels
        .map(
          (c) => IconButton(
            padding: .symmetric(horizontal: 3),
            onPressed: () => context.pushReplacement('/channel/${c.id}'),
            icon: ColorFiltered(
              colorFilter: ColorFilter.saturation(active == null || active == c.id ? 1 : 0.2),
              child: c.icon,
            ),
          ),
        )
        .toList();
  }
}
