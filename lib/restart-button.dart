import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_sample/gravity-game.dart';

class RestartButton {
  GarvityGame game;
  Sprite sprite;
  Rect rect;
  double size;

  bool enabled = false;

  RestartButton(this.game) {
    sprite = Sprite("controller/restart.png");
    size = game.screenSize.width / 4;
    rect = Rect.fromLTWH(
        game.screenSize.width / 2 - (size / 2), game.screenSize.height / 2 - (size / 2), size, size);
  }

  void render(Canvas canvas) {
    sprite.renderRect(canvas, rect);
  }

  void update(double t) {}

  void onTapDown(TapDownDetails details) {
    if (enabled) {
      if (rect.contains(details.globalPosition)) {
        game.onTapButton();
      }
    }
  }
}
