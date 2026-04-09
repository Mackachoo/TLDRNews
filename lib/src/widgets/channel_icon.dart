import 'package:flutter/material.dart';

class ChannelIcon extends StatelessWidget {
  const ChannelIcon({super.key, required this.icon, this.color, this.background});

  final String icon;
  final String? background;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(0),
          image: background != null
              ? DecorationImage(image: AssetImage(background!), fit: BoxFit.cover)
              : null,
        ),
        child: Row(
          children: [
            Spacer(flex: 10),
            Expanded(flex: 80, child: Image.asset(icon)),
            Spacer(flex: 10),
          ],
        ),
      ),
    );
  }

  // * Constructors --------------------------------

  factory ChannelIcon.fromId(String id) {
    switch (id) {
      case 'uk':
        return ChannelIcon.uk();
      case 'global':
        return ChannelIcon.global();
      case 'eu':
        return ChannelIcon.eu();
      case 'business':
        return ChannelIcon.business();
      case 'podcasts':
        return ChannelIcon.podcasts();
      case 'party':
        return ChannelIcon.party();
      default:
        throw ArgumentError('Unknown channel id: $id');
    }
  }

  factory ChannelIcon.uk() =>
      ChannelIcon(icon: 'assets/logos/tldr-uk.png', color: Color(0xFF4EA4AC));
  factory ChannelIcon.global() =>
      ChannelIcon(icon: 'assets/logos/tldr-global.png', color: Color(0xFF5C7AE7));
  factory ChannelIcon.eu() =>
      ChannelIcon(icon: 'assets/logos/tldr-eu.png', color: Color(0xFF1E4C94));
  factory ChannelIcon.business() =>
      ChannelIcon(icon: 'assets/logos/tldr-white.png', color: Color(0xFF4EB17D));
  factory ChannelIcon.party() =>
      ChannelIcon(icon: 'assets/logos/tldr-party.png', color: Color(0xFFE1E5EA));
  factory ChannelIcon.podcasts() => ChannelIcon(
    icon: 'assets/logos/tldr-white.png',
    background: 'assets/backgrounds/podcasts.png',
  );
}
