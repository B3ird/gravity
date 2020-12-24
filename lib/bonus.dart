import 'dart:math';
import 'dart:ui';

import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_sample/gravity-game.dart';

class Bonus {
  final GarvityGame mGame;
  Rect mRect;
  Sprite mSprite;
  Size mSize;
  double mVelocity;
  bool mDestroyed = false;

  // double mAngle = 5;

  Bonus(this.mGame) {
    double height = 120;
    mSize = Size(height/2.8, height);

    Random random = Random();
    double minPosition = 0;
    double maxPosition = mGame.screenSize.width;
    double x = random.nextDouble() * maxPosition + minPosition;
    double y = -mSize.height;
    Position position = Position(x, y);

    double minVelocity = 2.0;
    double maxVelocity = 3.0;
    mVelocity = random.nextDouble() * maxVelocity + minVelocity;
    mRect = Rect.fromLTWH(position.x, position.y, mSize.width, mSize.height);
    mSprite = Sprite("props/star.png");
  }

  void render(Canvas canvas) {
    if (!mDestroyed) {
      // canvas.save();
      // canvas.rotate(mAngle);
      mSprite.renderRect(canvas, mRect);
      // canvas.restore();
    }
  }

  void update(double t) {
    if (!mDestroyed) {
      mRect = Rect.fromLTWH(mRect.left, mRect.top + mVelocity, mSize.width, mSize.height);
      if (!mGame.player.dead) {
        if (mGame.player.mRect.contains(mRect.center)) {
          mGame.obtainBonus();
          mDestroyed = true;
        }
      }
      if (mRect.top > mGame.screenSize.height) {
        mDestroyed = true;
      }
    }
  }
}
