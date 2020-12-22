import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter_sample/gravity-game.dart';

class Background {
  Sprite sprite;
  Rect rect;

  Background(GarvityGame game) {
    sprite = Sprite("bg/background.png");
    rect = Rect.fromLTWH(
      0,
      game.screenSize.height - (game.tileSize * game.tilesByHeight),
      game.tileSize * game.tilesByWidth,
      game.tileSize * game.tilesByHeight,
    );
  }

  void render(Canvas canvas) {
    sprite.renderRect(canvas, rect);
  }

  void update(double t) {}
}
