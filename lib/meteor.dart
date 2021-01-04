import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_sample/gravity-game.dart';

class Meteor {
  final GarvityGame mGame;
  Rect mRect;
  Sprite mSprite;
  Size mSize;
  double mVelocity;
  bool mDestroyed = false;
  double mAngle = 5;

  bool isBurn = false;
  Animation burnAnimation;

  double minSize = 20;
  double maxSize = 50;

  Meteor(this.mGame) {
    Random random = Random();

    double width = random.nextDouble() * maxSize + minSize;
    double height = random.nextDouble() * maxSize + minSize;
    mSize = Size(width, height);

    double minPosition = 0;
    double maxPosition = mGame.screenSize.width;
    double x = random.nextDouble() * maxPosition + minPosition;
    double y = -mSize.height;
    Position position = Position(x, y);

    double minVelocity = 1.0;
    double maxVelocity = 2.5;
    mVelocity = random.nextDouble() * maxVelocity + minVelocity;
    mRect = Rect.fromLTWH(position.x, position.y, mSize.width, mSize.height);
    mSprite = Sprite("props/meteor.png");

    burnAnimation = Animation.sequenced("fx/burn_explosion.png", 13, textureHeight: 98, textureWidth: 98);


    int min = 1;
    int max = 3;
    int fileIndex = random.nextInt(max) + min;
    String filename = "meteor_" + fileIndex.toString() + ".mp3";
    double volume = (mSize.width*mSize.height)/(maxSize*maxSize);
    switch (fileIndex) {
      case 1:
        Flame.audio.play(filename, volume: 0.2);
        break;
      default:
        Flame.audio.play(filename, volume: volume);
    }

  }

  void render(Canvas canvas) {
    if (!mDestroyed) {
      // canvas.save();
      // canvas.rotate(mAngle);
      mSprite.renderRect(canvas, mRect);
      // canvas.restore();
    } else {
      if (isBurn) {
        if (!burnAnimation.done()) {
          burnAnimation.getSprite().renderRect(canvas, mRect);
        }
      }
    }
  }

  void update(double t) {
    if (!mDestroyed) {
      mRect = Rect.fromLTWH(mRect.left, mRect.top + mVelocity, mSize.width, mSize.height);
      if (mGame.player.mRect.contains(mRect.center)) {
        mGame.player.crash();
      }
      if (mRect.top > mGame.screenSize.height) {
        mDestroyed = true;
      }

      //block vertical move
      double sunLimit = mGame.screenSize.height / 4;
      if (mRect.top > mGame.screenSize.height - sunLimit) {
        burn();
      }
    } else {
      if (isBurn) {
        if (!burnAnimation.done()) {
          burnAnimation.update(t);
        } else {
          isBurn = false;
        }
      }
    }
  }

  void burn() {
    if (!mDestroyed) {
      mRect = Rect.fromLTWH(mRect.left - mSize.width / 2, mRect.top - mSize.height / 2, mSize.width * 2, mSize.height * 2);
      mDestroyed = true;
      isBurn = true;
      burnAnimation.loop = false;
      double volume = (mSize.width * mSize.height) / (maxSize * maxSize);
      print("volume " + volume.toString());
      Flame.audio.play("burn.mp3", volume: volume);
    }
  }
}
