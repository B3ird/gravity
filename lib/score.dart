import 'dart:ui';

import 'package:flame/position.dart';

class Score {

  Position position;
  Size size;
  String text;

  Score(String t, Position p, Size s) {
    position = p;
    text = t;
    size = s;
  }

  void render(Canvas canvas) {
    ParagraphBuilder paragraph = new ParagraphBuilder(ParagraphStyle());
    paragraph.pushStyle(TextStyle(color: Color(0xFFFFFFFF), fontSize: 48.0));
    paragraph.addText(text);
    var p = paragraph.build()..layout(new ParagraphConstraints(width: 180.0));
    canvas.drawParagraph(p, new Offset(position.x, position.y));
  }

  void update(double t) {}
}
