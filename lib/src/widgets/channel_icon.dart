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
          borderRadius: BorderRadius.circular(4),
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
}
