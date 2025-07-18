import 'package:flutter/material.dart';

class FingerData {
  final int pointerId;
  final Color color;
  Offset position;
  bool isWinner;
  double scale;

  FingerData({
    required this.pointerId,
    required this.color,
    required this.position,
    this.isWinner = false,
    this.scale = 1.0,
  });

  FingerData copyWith({
    int? pointerId,
    Color? color,
    Offset? position,
    bool? isWinner,
    double? scale,
  }) {
    return FingerData(
      pointerId: pointerId ?? this.pointerId,
      color: color ?? this.color,
      position: position ?? this.position,
      isWinner: isWinner ?? this.isWinner,
      scale: scale ?? this.scale,
    );
  }
}
