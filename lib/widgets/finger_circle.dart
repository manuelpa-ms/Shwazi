import 'package:flutter/material.dart';
import '../models/finger_data.dart';

class CirclePainter extends CustomPainter {
  final Map<int, FingerData> fingers;
  final Color? backgroundColor;
  final double winnerCircleScale;
  final double pulseScale;

  CirclePainter({
    required this.fingers,
    this.backgroundColor,
    this.winnerCircleScale = 1.0,
    this.pulseScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw circles for each finger
    for (final finger in fingers.values) {
      final paint = Paint()
        ..color = finger.color
        ..style = PaintingStyle.fill;

      // If this is the winner and we're animating, scale it up dramatically
      final radius = finger.isWinner 
          ? 45.0 * finger.scale * winnerCircleScale
          : 45.0 * finger.scale * pulseScale;
      
      canvas.drawCircle(finger.position, radius, paint);

      // Only draw border for non-winner circles or if winner hasn't grown too much
      if (!finger.isWinner || winnerCircleScale < 5.0) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        
        canvas.drawCircle(finger.position, radius, borderPaint);
      }
    }

    // Draw a static black circle on top of the expanding winner circle
    for (final finger in fingers.values) {
      if (finger.isWinner) {
        final blackPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

        final staticRadius = 45.0 * finger.scale * pulseScale; // Keep original size with pulse
        canvas.drawCircle(finger.position, staticRadius, blackPaint);

        // Add white border to the black circle
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        
        canvas.drawCircle(finger.position, staticRadius, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return fingers != oldDelegate.fingers || 
           backgroundColor != oldDelegate.backgroundColor ||
           winnerCircleScale != oldDelegate.winnerCircleScale ||
           pulseScale != oldDelegate.pulseScale;
  }
}
