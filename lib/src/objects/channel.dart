import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/widgets/channel_icon.dart';

class Channel {
  final String id;
  final String name;
  final ChannelIcon icon;

  Channel({required this.id, required this.name, required this.icon});
}

class Channels {
  static Channel get uk => Channel(
    id: 'uk',
    name: 'TLDR UK',
    icon: const ChannelIcon(icon: 'assets/logos/tldr-uk.png', color: Color(0xFF4EA4AC)),
  );
  static Channel get global => Channel(
    id: 'global',
    name: 'TLDR Global',
    icon: const ChannelIcon(icon: 'assets/logos/tldr-global.png', color: Color(0xFF5C7AE7)),
  );
  static Channel get eu => Channel(
    id: 'eu',
    name: 'TLDR EU',
    icon: const ChannelIcon(icon: 'assets/logos/tldr-eu.png', color: Color(0xFF1E4C94)),
  );
  static Channel get business => Channel(
    id: 'business',
    name: 'TLDR Business',
    icon: const ChannelIcon(icon: 'assets/logos/tldr-white.png', color: Color(0xFF4EB17D)),
  );
  static Channel get podcasts => Channel(
    id: 'podcasts',
    name: 'TLDR Podcasts',
    icon: const ChannelIcon(
      icon: 'assets/logos/tldr-white.png',
      background: 'assets/backgrounds/podcasts.png',
    ),
  );

  static List<Channel> get all => [uk, global, eu, business, podcasts];
  static List<IconButton> buttons(BuildContext context, [String? active]) {
    final channels = Channels.all;
    return channels
        .map(
          (c) => IconButton(
            padding: .symmetric(horizontal: 3),
            onPressed: () => context.pushReplacement('/channel/${c.id}'),
            icon: ColorFiltered(
              colorFilter: ColorFilter.saturation(active == null || active == c.id ? 1 : 0),
              child: c.icon,
            ),
          ),
        )
        .toList();
  }
}
