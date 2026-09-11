import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class VideoWidget extends StatelessWidget {
  const VideoWidget(this.video, {super.key});

  final YoutubeVideo video;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/video/${video.id}'),
      child: Column(
        spacing: 4,
        children: [
          SizedBox(
            width: double.infinity,
            child: video.imageUrl == null
                ? Container(
                    color: context.colors.tertiary,
                    width: double.infinity,
                    child: const Icon(Icons.videocam),
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
