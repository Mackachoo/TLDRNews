import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class VideoWidget extends StatelessWidget {
  const VideoWidget(this.video, {super.key});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: video.imageUrl == null
              ? Container(
                  color: context.colors.tertiary,
                  width: double.infinity,
                  child: PhosphorIcon(PhosphorIcons.video(PhosphorIconsStyle.bold)),
                )
              : Image.network(video.imageUrl!),
        ),
        Text(video.title),
      ],
    );
  }
}
