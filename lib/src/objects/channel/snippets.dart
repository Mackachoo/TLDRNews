import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/channel_icon.dart';

@JsonSerializable()
class ChannelSnippet {
  @JsonKey(includeToJson: false)
  final String id;
  final String name;
  ChannelIcon get icon => ChannelIcon.fromId(id);

  ChannelSnippet({required this.id, required this.name});

  Widget button(BuildContext context, {bool desaturate = false, void Function(String id)? onTap}) {
    bool active = context.uri.pathSegments.isNotEmpty && context.uri.pathSegments.last == id;
    return IconButton(
      padding: .zero,
      onPressed: !active && onTap != null ? () => onTap(id) : null,
      icon: ColorFiltered(
        colorFilter: ColorFilter.saturation(!desaturate || active ? 1 : 0.2),
        child: icon,
      ),
    );
  }
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
  static List<Widget> buttons(
    BuildContext context, {
    bool desaturate = false,
    void Function(String id)? onTap,
  }) => ChannelSnippets.all
      .map((c) => c.button(context, desaturate: desaturate, onTap: onTap))
      .toList();
}
