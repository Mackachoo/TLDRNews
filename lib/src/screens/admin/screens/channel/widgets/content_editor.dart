import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/objects/content/youtube_video.dart';
import 'package:tldrnews_app/src/objects/content/series.dart';
import 'package:tldrnews_app/src/screens/admin/screens/channel/channel_controller.dart';
import 'package:tldrnews_app/src/services/youtube_service.dart';

class ContentEditor {
  static void video(
    BuildContext context,
    AdminChannelController ctlr, [
    YoutubeVideo? video,
  ]) async {
    if (video == null) {
      String? url = await getUrl(context, 'video');
      if (url == null) return;
      video ??= await YouTubeService.videoUrlToYoutubeVideo(url);
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          constraints: BoxConstraints(maxWidth: 800),
          title: Text(video!.title.isEmpty ? 'Add new video' : 'Edit video'),
          content: Form(
            child: Column(
              spacing: 8,
              mainAxisSize: .min,
              children: [
                TextFormField(
                  initialValue: video.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) => video!.title = value,
                ),
                TextFormField(
                  initialValue: video.imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  onChanged: (value) => video!.imageUrl = value,
                ),
                TextFormField(
                  initialValue: video.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) => video!.description = value,
                  minLines: 3,
                  maxLines: 8,
                ),
                SizedBox(width: min(800, MediaQuery.of(context).size.width * 0.8)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
            ElevatedButton(
              onPressed: () {
                ctlr.setVideo(video!);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  static void series(BuildContext context, AdminChannelController ctlr, [Series? series]) async {
    if (series == null) {
      String? url = await getUrl(context, 'series');
      if (url == null) return;
      series = await YouTubeService.playlistUrlToSeries(url);
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          constraints: BoxConstraints(maxWidth: 800),
          title: Text(series!.title.isEmpty ? 'Add new series' : 'Edit series'),
          content: Form(
            child: Column(
              spacing: 8,
              mainAxisSize: .min,
              children: [
                TextFormField(
                  initialValue: series.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) => series!.title = value,
                ),
                TextFormField(
                  initialValue: series.imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  onChanged: (value) => series!.imageUrl = value,
                ),
                TextFormField(
                  initialValue: series.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) => series!.description = value,
                  minLines: 3,
                  maxLines: 8,
                ),
                SizedBox(width: min(800, MediaQuery.of(context).size.width * 0.8)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
            ElevatedButton(
              onPressed: () {
                ctlr.setSeries(series!);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  static Future<String?> getUrl(BuildContext context, String title) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          constraints: BoxConstraints(minWidth: 600),
          title: Text('Add new $title'),
          content: Column(
            mainAxisSize: .min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Content URL'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Confirm'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}
