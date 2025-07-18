import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isVisible;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        remainingSeconds.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
