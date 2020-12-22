import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter_sample/gravity-game.dart';

class Layout {
  Sprite sprite;
  Rect rect;

  Layout(GarvityGame game) {
    sprite = Sprite("fx/blood_screen.png");
    rect = Rect.fromLTWH(
      0,
      0,
      game.screenSize.width,
      game.screenSize.height,
    );

  }

  void render(Canvas canvas) {
    sprite.renderRect(canvas, rect);
  }

  void update(double t) {}
}
