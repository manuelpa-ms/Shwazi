import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_logic.dart';
import '../widgets/finger_circle.dart';
import '../widgets/circular_progress_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<GameLogic>(
        builder: (context, gameLogic, child) {
          return Stack(
            children: [
              // Main touch detection area
              Listener(
                onPointerDown: (details) {
                  gameLogic.addFinger(
                    details.pointer,
                    details.localPosition,
                  );
                },
                onPointerMove: (details) {
                  gameLogic.updateFingerPosition(
                    details.pointer,
                    details.localPosition,
                  );
                },
                onPointerUp: (details) {
                  gameLogic.removeFinger(details.pointer);
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: CirclePainter(
                      fingers: gameLogic.activeFingers,
                      backgroundColor: gameLogic.winnerBackgroundColor,
                      winnerCircleScale: gameLogic.winnerCircleScale,
                      pulseScale: gameLogic.pulseScale,
                    ),
                  ),
                ),
              ),
              
              // Circular progress bar overlay
              CircularProgressBar(
                progress: gameLogic.countdownProgress,
                isVisible: gameLogic.isProgressBarVisible,
                shouldReset: gameLogic.shouldResetProgress,
                onResetComplete: gameLogic.onProgressResetComplete,
              ),
              
              // Instructions overlay - only show on first launch
              if (gameLogic.gameState == GameState.waiting && 
                  gameLogic.activeFingers.isEmpty &&
                  !gameLogic.hasShownInstructions)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Touch the screen with multiple fingers',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Need 2+ fingers to start selection',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
              // Debug info (finger count) - only in debug builds
              if (kDebugMode)
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Fingers: ${gameLogic.activeFingers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
