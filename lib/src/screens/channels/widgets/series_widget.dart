import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class SeriesWidget extends StatelessWidget {
  const SeriesWidget(this.series, {super.key});

  final Series series;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        height: 56,
        child: series.imageUrl == null
            ? Container(color: context.colors.onSurfaceVariant)
            : Image.network(
                series.imageUrl!,
                width: 100,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 200,
                cacheHeight: 112,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: context.colors.onSurfaceVariant),
              ),
      ),
      title: Text(series.title),
      subtitle: Text(series.description ?? '', maxLines: 2, overflow: .ellipsis),
      trailing: Card(
        child: Padding(
          padding: .all(6),
          child: Text(series.videoIds.length.toString(), style: context.textTheme.labelLarge),
        ),
      ),
    );
  }
}
