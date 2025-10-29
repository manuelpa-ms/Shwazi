import 'package:flutter/material.dart';

class ColorGenerator {
  static const List<Color> _colors = [
    Colors.red,
    Colors.green,
    Color.fromARGB(255, 233, 30, 148),
    Colors.teal,
    Colors.amber,
    Colors.indigo,
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
