import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_sample/gravity-game.dart';

//FROM https://github.com/jeremy-giles/Flame-Virtual-Joystick
class Controller {

  final GarvityGame game;

  double controllerSize;
  double backgroundAspectRatio = 2.0;
  Rect backgroundRect;
  Sprite backgroundSprite;

  double knobAspectRatio = 1.2;
  Rect knobRect;
  Sprite knobSprite;

  bool dragging = false;
  Offset dragPosition;

  bool enabled = true;

  Controller(this.game) {
    controllerSize = game.screenSize.width / 6.0;
    backgroundSprite = Sprite('controller/joystick_background.png');
    knobSprite = Sprite('controller/joystick_knob.png');

    initialize();
  }

  void initialize() async {
    // The circle radius calculation that will contain the background
    // image of the joystick
    var radius = (controllerSize * backgroundAspectRatio) / 2;

    // Offset osBackground = Offset(
    //     radius + (radius / 2),
    //     game.screenSize.height - (radius + (radius / 2))
    // );

    Offset osBackground = Offset(
        game.screenSize.width/2,
        game.screenSize.height - (radius + (radius / 2))
    );

    backgroundRect = Rect.fromCircle(
        center: osBackground,
        radius: radius
    );

    // The circle radius calculation that will contain the knob
    // image of the joystick
    radius = (controllerSize * knobAspectRatio) / 2;

    Offset osKnob = Offset(
        backgroundRect.center.dx,
        backgroundRect.center.dy
    );
    knobRect = Rect.fromCircle(
        center: osKnob,
        radius: radius
    );
    dragPosition = knobRect.center;
  }

  void render(Canvas canvas) {
    backgroundSprite.renderRect(canvas, backgroundRect);
    knobSprite.renderRect(canvas, knobRect);
  }

  void update(double t) {
    if (enabled) {
      if (dragging) {
        double _radAngle = atan2(
            dragPosition.dy - backgroundRect.center.dy,
            dragPosition.dx - backgroundRect.center.dx);

        // Update rad angle
        // game.playerShip.lastMoveRadAngle = _radAngle; ////USE LISTENER INSTEAD
        game.onControllerAngleChange(_radAngle);

        // Distance between the center of joystick background & drag position
        Point p = Point(backgroundRect.center.dx, backgroundRect.center.dy);
        double dist = p.distanceTo(Point(dragPosition.dx, dragPosition.dy));

        // The maximum distance for the knob position the edge of
        // the background + half of its own size. The knob can wander in the
        // background image, but not outside.
        dist = dist < (controllerSize * backgroundAspectRatio / 2)
            ? dist
            : (controllerSize * backgroundAspectRatio / 2);

        // Calculation the knob position
        double nextX = dist * cos(_radAngle);
        double nextY = dist * sin(_radAngle);
        Offset nextPoint = Offset(nextX, nextY);

        Offset diff = Offset(
            backgroundRect.center.dx + nextPoint.dx,
            backgroundRect.center.dy + nextPoint.dy) - knobRect.center;
        knobRect = knobRect.shift(diff);
      } else {
        // The drag position is, at this moment, that of the center of the
        // background of the joystick. It calculates the difference between this
        // position and the current position of the knob to place the center of
        // the background.
        Offset diff = dragPosition - knobRect.center;
        knobRect = knobRect.shift(diff);
      }
    }
  }

  void onPanStart(DragStartDetails details) {
    if (knobRect.contains(details.globalPosition)) {
      dragging = true;
      // game.playerShip.move = true;//TODO
      // game.controllerMove = true;
      game.onControllerMoveChange(true);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (dragging) {
      dragPosition = details.globalPosition;
    }
  }

  void onPanEnd(DragEndDetails details) {
    dragging = false;
    // Reset drag position to the center of joystick background
    dragPosition = backgroundRect.center;
    // Stop move player ship
    // game.playerShip.move = false;//USE LISTENER INSTEAD
    game.onControllerMoveChange(false);
  }

}