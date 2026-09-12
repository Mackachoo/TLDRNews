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
      onTap: () => context.push('/video/${video.id}'),
      child: Column(
        spacing: 4,
        children: [
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: video.imageUrl == null || video.imageUrl!.isEmpty
                  ? _VideoPlaceholder(context: context)
                  : Image.network(
                      video.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _VideoPlaceholder(context: context),
                    ),
            ),
          ),
          Text(video.title, style: context.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      color: context.colors.tertiary,
      alignment: Alignment.center,
      child: Icon(Icons.video_library_outlined, color: context.colors.onTertiary, size: 40),
    );
  }
}
