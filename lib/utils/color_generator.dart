import 'package:flutter/material.dart';

class ColorGenerator {
  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.brown,
  ];

  static Color getColor(int index) {
    return _colors[index % _colors.length];
  }

  static int get colorCount => _colors.length;
}
