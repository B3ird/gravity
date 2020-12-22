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

  Bonus(this.mGame){
    mSize = Size(50,50);

    Random random = Random();
    double minPosition = 0;
    double maxPosition = mGame.screenSize.width;
    double x = random.nextDouble() * maxPosition + minPosition;
    double y = -mSize.height;
    Position position = Position(x, y);

    double minVelocity = 1.5;
    double maxVelocity = 3.0;
    mVelocity = random.nextDouble() * maxVelocity + minVelocity;
    mRect = Rect.fromLTWH(position.x, position.y, mSize.width, mSize.height);
    mSprite = Sprite("props/bonus.png");
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
      if (mGame.player.mRect.contains(mRect.center)) {
        mGame.obtainBonus();
        mDestroyed = true;
      }
      if (mRect.top > mGame.screenSize.height) {
        mDestroyed = true;
      }
    }
  }
}
