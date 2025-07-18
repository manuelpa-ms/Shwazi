import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/finger_data.dart';
import '../utils/color_generator.dart';

enum GameState { waiting, countdown, winnerSelected, animating }

class GameLogic extends ChangeNotifier {
  final Map<int, FingerData> _activeFingers = {};
  GameState _gameState = GameState.waiting;
  Timer? _countdownTimer;
  int _remainingSeconds = 3;
  int _colorIndex = 0;
  FingerData? _winner;
  bool _hasShownInstructions = false;
  Color? _winnerBackgroundColor;
  double _winnerCircleScale = 1.0;

  Map<int, FingerData> get activeFingers => Map.unmodifiable(_activeFingers);
  GameState get gameState => _gameState;
  int get remainingSeconds => _remainingSeconds;
  FingerData? get winner => _winner;
  Color? get winnerBackgroundColor => _winnerBackgroundColor;
  bool get hasShownInstructions => _hasShownInstructions;
  double get winnerCircleScale => _winnerCircleScale;

  void addFinger(int pointerId, Offset position) {
    if (_gameState == GameState.winnerSelected) {
      _resetGame();
    }

    if (!_activeFingers.containsKey(pointerId)) {
      // Mark instructions as shown once user starts interacting
      if (!_hasShownInstructions) {
        _hasShownInstructions = true;
      }

      final color = ColorGenerator.getColor(_colorIndex);
      _activeFingers[pointerId] = FingerData(
        pointerId: pointerId,
        color: color,
        position: position,
        scale: 1.5, // Start with larger scale for entry animation
      );
      _colorIndex++;
      
      // Animate scale down to normal size
      _animateFingerEntry(pointerId);
      
      _checkCountdownCondition();
      notifyListeners();
    }
  }

  void updateFingerPosition(int pointerId, Offset position) {
    if (_activeFingers.containsKey(pointerId)) {
      _activeFingers[pointerId]!.position = position;
      notifyListeners();
    }
  }

  void removeFinger(int pointerId) {
    if (_activeFingers.containsKey(pointerId)) {
      _activeFingers.remove(pointerId);
      _checkCountdownCondition();
      notifyListeners();
    }
  }

  void _animateFingerEntry(int pointerId) {
    // Simple scale animation - in a real implementation, you'd use AnimationController
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_activeFingers.containsKey(pointerId)) {
        timer.cancel();
        return;
      }

      final finger = _activeFingers[pointerId]!;
      if (finger.scale > 1.0) {
        finger.scale = (finger.scale - 0.05).clamp(1.0, 1.5);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _checkCountdownCondition() {
    if (_activeFingers.length >= 2 && _gameState == GameState.waiting) {
      _startCountdown();
    } else if (_activeFingers.length < 2 && _gameState == GameState.countdown) {
      _cancelCountdown();
    }
  }

  void _startCountdown() {
    _gameState = GameState.countdown;
    _remainingSeconds = 3;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      notifyListeners();
      
      if (_remainingSeconds <= 0) {
        _selectWinner();
        timer.cancel();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _gameState = GameState.waiting;
    _remainingSeconds = 3;
    notifyListeners();
  }

  void _selectWinner() {
    if (_activeFingers.isNotEmpty) {
      _gameState = GameState.animating;
      final fingersList = _activeFingers.values.toList();
      final random = Random();
      final selectedIndex = random.nextInt(fingersList.length);
      
      _winner = fingersList[selectedIndex];
      _winner!.isWinner = true;
      _winnerBackgroundColor = _winner!.color;
      
      // Remove losing fingers immediately
      final winnerPointerId = _winner!.pointerId;
      _activeFingers.removeWhere((key, value) => key != winnerPointerId);
      
      notifyListeners();
      
      // Start circle expansion animation
      _animateCircleExpansion();
    }
  }

  void _animateCircleExpansion() {
    const steps = 45; // 45 frames for faster expansion (~0.75 seconds)
    const stepDuration = Duration(milliseconds: 17); // ~60fps
    
    int currentStep = 0;
    
    Timer.periodic(stepDuration, (timer) {
      currentStep++;
      // Scale exponentially for dramatic effect - from 1.0 to ~50.0
      _winnerCircleScale = 1.0 + (currentStep / steps) * (currentStep / steps) * 100.0;
      notifyListeners();
      
      if (currentStep >= steps) {
        timer.cancel();
        _gameState = GameState.winnerSelected;
        notifyListeners();
      }
    });
  }

  void _resetGame() {
    _countdownTimer?.cancel();
    _activeFingers.clear();
    _gameState = GameState.waiting;
    _remainingSeconds = 3;
    _winner = null;
    _winnerBackgroundColor = null;
    _winnerCircleScale = 1.0;
    _colorIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
