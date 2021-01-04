import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_sample/background.dart';
import 'package:flutter_sample/controller.dart';
import 'package:flutter_sample/meteor.dart';
import 'package:flutter_sample/player.dart';
import 'package:flutter_sample/restart-button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bonus.dart';
import 'layout.dart';

class GarvityGame extends Game with TapDetector {
  Size screenSize;
  bool hasWon = false;
  double tileSize;
  int tilesByWidth = 5;
  int tilesByHeight = 15;
  List<Meteor> meteors;
  List<Bonus> bonuses;

  Background background;
  Layout layout;
  Player player;

  // Score score;

  Controller controller;
  RestartButton button;

  double controllerAngle = 0.0;
  bool controllerMove = false;

  double ellapsedTime;
  double ellapsedTimeScore;
  double bonus;

  double lastMeteorSpawn;
  double spawnMeteorDelay;
  double spawnMeteorDelayMin;
  double spawnMeteorDelayFactor;

  double lastBonusSpawn;
  double spawnBonusDelay;
  double spawnBonusDelayMax;
  double spawnBonusDelayFactor;

  bool gameOver;
  String score;
  bool scoreSaved;

  bool pause = false;

  GarvityGame() {
    initialize();
  }

  void initialize() async {
    scoreSaved = false;
    ellapsedTime = 0;
    ellapsedTimeScore = 0;

    //meteor
    lastMeteorSpawn = 0;
    spawnMeteorDelay = 3.0;
    spawnMeteorDelayMin = 0.5;
    spawnMeteorDelayFactor = 0.9;

    //bonus
    bonus = 0;
    lastBonusSpawn = 0;
    spawnBonusDelay = 5.0;
    spawnBonusDelayMax = 15;
    spawnBonusDelayFactor = 1.1;

    gameOver = false;

    preloadImages();
    meteors = List<Meteor>();
    bonuses = List<Bonus>();
    resize(await Flame.util.initialDimensions());
    // tileSize = screenSize.width / tilesByWidth;
    background = Background(this);
    player = Player(this, screenSize.width / 2, screenSize.height / 2);
    controller = Controller(this);
    button = RestartButton(this);
    layout = Layout(this);
  }

  void setPause(bool state) {
    print("pause " + state.toString());
    pause = state;
    if (pause) { //avoid game to continue counting points
      player.burn();
    }
  }

  @override
  void render(Canvas canvas) {
    background.render(canvas);

    TextConfig config = TextConfig(fontSize: 48.0, color: Color(0xFFFFFFFF), textAlign: TextAlign.center);
    config.render(canvas, score, Position(screenSize.width / 2, screenSize.height / 2 - button.size), anchor: Anchor.center);

    // score.render(canvas);
    player.render(canvas);
    meteors.forEach((Meteor meteor) {
      meteor.render(canvas);
    });
    bonuses.forEach((Bonus bonus) {
      bonus.render(canvas);
    });
    if (gameOver) {
      button.render(canvas);
      layout.render(canvas);
    } else {
      controller.render(canvas);
    }
  }

  @override
  void update(double t) {
    if (!pause) {
      ellapsedTime += t;

      controller.update(t);
      player.update(t);

      int formatedScore = (ellapsedTimeScore * 100).toInt() + bonus.toInt();
      score = formatedScore.toString() + " pts";

      if (gameOver) {
        button.enabled = true;
        controller.enabled = false;
        if (!scoreSaved) {
          scoreSaved = true;
          saveScore(formatedScore);
        }
      } else {
        ellapsedTimeScore = ellapsedTime;
        button.enabled = false;
        controller.enabled = true;
      }

      if (ellapsedTime - lastMeteorSpawn > spawnMeteorDelay) {
        if (spawnMeteorDelay > spawnMeteorDelayMin) {
          spawnMeteorDelay = spawnMeteorDelay * spawnMeteorDelayFactor;
        }
        lastMeteorSpawn = ellapsedTime;
        spawnMeteor();
        // print("spawnDelay " + spawnDelay.toString());
      }

      if (ellapsedTime - lastBonusSpawn > spawnBonusDelay) {
        if (spawnBonusDelay < spawnBonusDelayMax) {
          spawnBonusDelay = spawnBonusDelay * spawnBonusDelayFactor;
        }
        lastBonusSpawn = ellapsedTime;
        spawnBonus();
      }

      meteors.forEach((Meteor meteor) {
        meteor.update(t);
      });

      bonuses.forEach((Bonus bonus) {
        bonus.update(t);
      });
    }
  }

  @override
  void resize(Size size) {
    super.resize(size);
    screenSize = size;
    tileSize = screenSize.width / tilesByWidth;
  }

  void spawnMeteor() {
    meteors.add(Meteor(this));
  }

  void spawnBonus() {
    // print("SPAWN BONUS " + lastBonusSpawn.toString());
    bonuses.add(Bonus(this));
  }

  void preloadImages() {
    Flame.images.loadAll(<String>[
      'bg/background.png',
      'characters/player_left.png',
      'characters/player_front.png',
      'characters/player_right.png',
      'controller/joystick_background.png',
      'controller/joystick_knob.png',
      'controller/restart.png',
      'props/meteor.png',
      'props/bonus.png',
      'fx/blood_explosion.png',
      'fx/blood_screen.png',
      'fx/burn_explosion.png',
    ]);
  }

  //GESTURE
  void onPanStart(DragStartDetails details) {
    controller.onPanStart(details);
  }

  void onPanUpdate(DragUpdateDetails details) {
    controller.onPanUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    controller.onPanEnd(details);
  }

  void onTapDown(TapDownDetails details) {
    button.onTapDown(details);
  }

  //Button listeners
  void onTapButton() {
    print("fire");
    initialize();
  }

  //Controller listeners
  void onControllerAngleChange(double angle) {
    player.lastMoveRadAngle = angle;
  }

  void onControllerMoveChange(bool move) {
    player.move = move;
  }

  saveScore(int score) async {
    print("saveScore");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList("scores");
    if (scores == null) {
      scores = List();
    }
    scores.add(score.toString());
    await prefs.setStringList('scores', scores);
  }

  void obtainBonus() {
    Flame.audio.play("get_bonus.mp3");
    bonus += 1000;
  }
}
