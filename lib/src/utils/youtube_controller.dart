import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

enum PlayerDisplayMode { none, floating, fullScreen }

class YoutubeController extends ChangeNotifier {
  // * Finals -------------------------------

  Widget? scaffoldPlayer;
  final controller = YoutubePlayerController(
    params: const YoutubePlayerParams(
      mute: false,
      enableCaption: true,
      showControls: true,
      showFullscreenButton: true,
      origin: 'https://www.youtube-nocookie.com',
    ),
  );

  // * State -------------------------------

  PlayerDisplayMode _displayMode = PlayerDisplayMode.none;
  PlayerDisplayMode get displayMode => _displayMode;
  set displayMode(PlayerDisplayMode mode) {
    if (_displayMode != mode) {
      _displayMode = mode;
      notifyListeners();
    }
  }

  Widget player({PlayerDisplayMode mode = .fullScreen}) => ListenableBuilder(
    listenable: this,
    builder: (context, child) {
      if (displayMode != mode || scaffoldPlayer == null) return SizedBox.shrink();
      return Hero(
        tag: 'youtube-player',
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = mode == .floating
                ? min(constraints.maxWidth * 2 / 3, 800)
                : constraints.maxWidth;
            return SizedBox(
              width: width,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(child: scaffoldPlayer!),
                    if (mode == .floating)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: PhosphorIcon(PhosphorIcons.x(), color: Colors.white),
                          onPressed: stop,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  void start(String? id, [PlayerDisplayMode mode = .fullScreen]) {
    if (id == null) return;
    controller.cueVideoById(videoId: id);
    displayMode = mode;
  }

  void stop() {
    controller.stopVideo();
    displayMode = .none;
  }
}
