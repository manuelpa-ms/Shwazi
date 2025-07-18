import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CircularProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final bool isVisible;
  final bool shouldReset;
  final VoidCallback? onResetComplete;

  const CircularProgressBar({
    super.key,
    required this.progress,
    required this.isVisible,
    this.shouldReset = false,
    this.onResetComplete,
  });

  @override
  State<CircularProgressBar> createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends State<CircularProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _resetAnimationController;
  late Animation<double> _resetAnimation;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _resetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Slightly longer for smoother reverse animation
      vsync: this,
    );
    _resetAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeInQuart, // Fast start, slow end for dramatic effect
    ));

    _resetAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resetAnimationController.reset();
        widget.onResetComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(CircularProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldReset && !oldWidget.shouldReset) {
      // Capture the current progress when reset starts
      _lastProgress = oldWidget.progress;
      _resetAnimationController.forward();
    }
    
    // Update _lastProgress when not resetting
    if (!widget.shouldReset) {
      _lastProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _resetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer( // Allow touch events to pass through
        child: AnimatedBuilder(
          animation: _resetAnimation,
          builder: (context, child) {
            double displayProgress;
            
            if (widget.shouldReset) {
              // During reset: animate from last progress down to 0
              displayProgress = _lastProgress * _resetAnimation.value;
            } else {
              // Normal operation: show current progress
              displayProgress = widget.progress;
            }
            
            return CustomPaint(
              painter: CircularProgressPainter(
                progress: displayProgress,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;

  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final strokeWidth = 8.0;
    final halfStroke = strokeWidth / 2;
    
    // Platform-aware corner radius
    double cornerRadius;
    if (!kIsWeb && Platform.isIOS) {
      // iPhone corner radii are much larger - varies by model
      // iPhone 14/15: ~47-55px, iPhone 14/15 Pro: ~55px
      // Scale based on screen size for different iPhone models
      final screenDiagonal = math.sqrt(size.width * size.width + size.height * size.height);
      cornerRadius = screenDiagonal * 0.06; // ~6% of diagonal for iOS
    } else {
      // Android phones typically have smaller corner radii
      // Most Samsung/Google phones: ~20-30px
      cornerRadius = math.min(size.width, size.height) * 0.035; // ~3.5% for Android
    }
    
    // Create a custom path that starts at 12 o'clock (top center)
    final path = Path();
    final rect = Rect.fromLTWH(
      halfStroke, 
      halfStroke, 
      size.width - strokeWidth, 
      size.height - strokeWidth
    );
    
    // Start at top center (12 o'clock)
    final startX = rect.center.dx;
    final startY = rect.top;
    path.moveTo(startX, startY);
    
    // Create the rounded rectangle path starting from top center and going clockwise
    // Top edge (center to right)
    path.lineTo(rect.right - cornerRadius, rect.top);
    // Top-right corner
    path.arcToPoint(
      Offset(rect.right, rect.top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    // Right edge
    path.lineTo(rect.right, rect.bottom - cornerRadius);
    // Bottom-right corner
    path.arcToPoint(
      Offset(rect.right - cornerRadius, rect.bottom),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    // Bottom edge
    path.lineTo(rect.left + cornerRadius, rect.bottom);
    // Bottom-left corner
    path.arcToPoint(
      Offset(rect.left, rect.bottom - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    // Left edge
    path.lineTo(rect.left, rect.top + cornerRadius);
    // Top-left corner
    path.arcToPoint(
      Offset(rect.left + cornerRadius, rect.top),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    // Top edge (left to center)
    path.lineTo(startX, startY);
    
    // Calculate the total path length
    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;
    
    // Calculate how far along the path we should draw
    final progressLength = totalLength * progress;
    
    // Extract the portion of the path for our progress
    final progressPath = pathMetrics.extractPath(0, progressLength);
    
    // Draw the progress path
    final progressPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(progressPath, progressPaint);
    
    // Add a glowing head effect at the current progress position
    if (progress < 1.0 && progressLength > 0) {
      final tangent = pathMetrics.getTangentForOffset(progressLength);
      
      if (tangent != null) {
        final headPosition = tangent.position;
        
        // Bright head
        final glowPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(headPosition, 6.0, glowPaint);
        
        // Outer glow
        final outerGlowPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(headPosition, 12.0, outerGlowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
