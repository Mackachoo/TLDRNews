import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/content/video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class VideoWidget extends StatelessWidget {
  const VideoWidget(this.video, {super.key});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/video/${video.id}'),
      child: Column(
        spacing: 4,
        children: [
          SizedBox(
            width: double.infinity,
            child: video.imageUrl == null
                ? Container(
                    color: context.colors.tertiary,
                    width: double.infinity,
                    child: PhosphorIcon(PhosphorIcons.video(PhosphorIconsStyle.bold)),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(video.imageUrl!, fit: BoxFit.cover),
                  ),
          ),
          Text(video.title, style: context.textTheme.titleSmall),
        ],
      ),
    );
  }
}
