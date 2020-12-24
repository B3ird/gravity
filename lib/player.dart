import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_sample/gravity-game.dart';
import 'package:vector_math/vector_math.dart';

class Player {
  final GarvityGame mGame;
  Sprite mSprite;
  Vector2 mLocation;
  Rect mRect;

  double playerHeight = 70;
  Size playerSize;

  Animation idleAnimation;
  Animation burnAnimation;
  Animation crashAnimation;

  bool dead = false;
  bool isBurn = false;

  double speed = 160.0;
  bool move = false;
  double lastMoveRadAngle = 0.0;

  Player(this.mGame, double x, double y) {
    List<Sprite> idleSprites = List();
    idleSprites.add(Sprite("characters/player_left.png"));
    idleSprites.add(Sprite("characters/player_front.png"));
    idleSprites.add(Sprite("characters/player_right.png"));
    idleSprites.add(Sprite("characters/player_front.png"));
    idleAnimation = Animation.spriteList(idleSprites, stepTime: 0.8);

    burnAnimation = Animation.sequenced("fx/burn_explosion.png", 13, textureHeight: 98, textureWidth: 98);
    crashAnimation = Animation.sequenced("fx/blood_explosion.png", 5, textureHeight: 123, textureWidth: 123);
    playerSize = Size(playerHeight / 1.37, playerHeight);
    mLocation = Vector2(x, y);
    mSprite = Sprite("characters/player_left.png");
    mRect = Rect.fromLTWH(x, y, playerSize.width, playerSize.height); //ratio asset
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(mRect.center.dx, mRect.center.dy);
    canvas.rotate(lastMoveRadAngle == 0.0 ? 0.0 : lastMoveRadAngle + (pi / 2));
    canvas.translate(-mRect.center.dx, -mRect.center.dy);

    if (dead) {
      if (isBurn) {
        if (!burnAnimation.done()) {
          burnAnimation.getSprite().renderRect(canvas, mRect);
        }
      } else {
        if (!crashAnimation.done()) {
          crashAnimation.getSprite().renderRect(canvas, mRect);
        }
      }
    } else if (move) {
      mSprite.renderRect(canvas, mRect);
    } else {
      //idle
      Random random = Random();
      double min = 0.8;
      double max = 5.0;
      idleAnimation.stepTime = random.nextDouble() * max + min;
      idleAnimation.getSprite().renderRect(canvas, mRect);
    }

    canvas.restore();
  }

  void update(double t) {
    idleAnimation.update(t);
    if (dead) {
      if (isBurn) {
        if (!burnAnimation.done()) {
          burnAnimation.update(t);
        }
      } else {
        if (!crashAnimation.done()) {
          crashAnimation.update(t);
        }
      }
    } else {
      double angle = lastMoveRadAngle * 180 / pi;
      if (move) {
        // print("angle " + angle.toString());
        if (angle > -90 && angle < 90) {
          mSprite = Sprite("characters/player_right.png");
        } else {
          mSprite = Sprite("characters/player_left.png");
        }

        double nextX = (speed * t) * cos(lastMoveRadAngle);
        double nextY = (speed * t) * sin(lastMoveRadAngle);
        // print("nextX :" + nextX.toString());
        Offset nextPoint = Offset(nextX, nextY);

        Offset diffBase = Offset(mRect.center.dx + nextPoint.dx, mRect.center.dy + nextPoint.dy) - mRect.center;

        mRect = mRect.shift(diffBase);
      } else {
        //fall
        mSprite = Sprite("characters/player_front.png");

        // print("angle :" + angle.toString());
        double corrector = 0.2;
        if (angle > -90 && angle < 90) {
          lastMoveRadAngle = (angle - corrector) * pi / 180;
        } else {
          lastMoveRadAngle = (angle + corrector) * pi / 180;
        }

        double gravity = 0.6;
        mRect = Rect.fromLTWH(mRect.left, mRect.top + gravity, playerSize.width, playerSize.height);
      }

      //infinite horizontal move
      if (mRect.left < -playerSize.width) {
        mRect = Rect.fromLTWH(mGame.screenSize.width, mRect.top, playerSize.width, playerSize.height);
      } else if (mRect.left > mGame.screenSize.width) {
        mRect = Rect.fromLTWH(-playerSize.width, mRect.top, playerSize.width, playerSize.height);
      }
      //block vertical move
      double sunLimit = mGame.screenSize.height / 4;
      if (mRect.top < -playerSize.height / 2) {
        mRect = Rect.fromLTWH(mRect.left, -playerSize.height / 2, playerSize.width, playerSize.height);
      } else if (mRect.top > mGame.screenSize.height - sunLimit) {
        burn();
      }
    }
  }

  void burn() {
    if (!dead) {
      dead = true;
      isBurn = true;
      mRect = Rect.fromLTWH(mRect.left-playerSize.width/2, mRect.top-playerSize.height/2, playerSize.width*2, playerSize.height*2);
      burnAnimation.loop = false;
      mGame.gameOver = true;
      Flame.audio.play("burn.mp3");
      Flame.audio.play("wilhelm.mp3", volume: 0.05);
    }
  }

  void crash() {
    if (!dead) {
      dead = true;
      isBurn = false;
      mRect = Rect.fromLTWH(mRect.left-playerSize.width/2, mRect.top-playerSize.height/2, playerSize.width*2, playerSize.height*2);
      crashAnimation.loop = false;
      mGame.gameOver = true;
      Random random = Random();
      int min = 1;
      int max = 3;
      int fileIndex = random.nextInt(max) + min;
      String filename = "crash_" + fileIndex.toString() + ".mp3";
      switch (fileIndex) {
        case 1:
          Flame.audio.play(filename, volume: 0.4);
          break;
        default:
          Flame.audio.play(filename);
      }
    }
  }
}
