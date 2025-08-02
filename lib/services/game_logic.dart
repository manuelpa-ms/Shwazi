import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finger_data.dart';
import '../utils/color_generator.dart';

enum GameState { waiting, countdown, winnerSelected, animating }

class GameLogic extends ChangeNotifier with WidgetsBindingObserver {
  final Map<int, FingerData> _activeFingers = {};
  GameState _gameState = GameState.waiting;
  Timer? _countdownTimer;
  Timer? _resetTimer; // Track reset timer separately
  Timer? _winnerDisplayTimer; // Timer to keep winner displayed
  int _remainingSeconds = 3;
  double _countdownProgress = 0.0; // Progress from 0.0 to 1.0
  bool _shouldResetProgress = false;
  int _colorIndex = 0;
  FingerData? _winner;
  bool _hasShownInstructions = false;
  Color? _winnerBackgroundColor;
  double _winnerCircleScale = 1.0;
  Timer? _pulseTimer;
  double _pulseScale = 1.0;
  bool _pulseDirection = true; // true = growing, false = shrinking
  int _previousFingerCount = 0; // Track previous finger count for countdown reset
  bool _isInWinnerDisplayMode = false; // Track if we're in the winner display period

  GameLogic() {
    // Add this instance as an app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  Map<int, FingerData> get activeFingers => Map.unmodifiable(_activeFingers);
  GameState get gameState => _gameState;
  int get remainingSeconds => _remainingSeconds;
  double get countdownProgress => _countdownProgress;
  bool get shouldResetProgress => _shouldResetProgress;
  bool get isProgressBarVisible => _gameState == GameState.countdown || _shouldResetProgress;
  FingerData? get winner => _winner;
  Color? get winnerBackgroundColor => _winnerBackgroundColor;
  bool get hasShownInstructions => _hasShownInstructions;
  double get winnerCircleScale => _winnerCircleScale;
  double get pulseScale => _pulseScale;
  bool get isInWinnerDisplayMode => _isInWinnerDisplayMode;

  void addFinger(int pointerId, Offset position) {
    if (_gameState == GameState.winnerSelected && !_isInWinnerDisplayMode) {
      _resetGame();
    }

    // If a finger is added during winner display mode, reset and start tracking
    if (_isInWinnerDisplayMode) {
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
      
      // Start pulse animation if this is the first or second finger
      if (_activeFingers.length >= 1) {
        _startPulseAnimation();
      }
      
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
    // Don't remove the winning finger during winner display mode
    if (_isInWinnerDisplayMode && _winner?.pointerId == pointerId) {
      return;
    }

    if (_activeFingers.containsKey(pointerId)) {
      _activeFingers.remove(pointerId);
      
      // Stop pulse animation if no fingers remain
      if (_activeFingers.isEmpty) {
        _stopPulseAnimation();
      }
      
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

  void _startPulseAnimation() {
    // Stop any existing pulse animation
    _pulseTimer?.cancel();
    
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_activeFingers.isEmpty || _gameState != GameState.waiting && _gameState != GameState.countdown) {
        timer.cancel();
        _pulseScale = 1.0;
        return;
      }

      // Pulse between 0.9 and 1.1 (20% variation)
      const pulseRange = 0.1;
      const pulseSpeed = 0.02;
      
      if (_pulseDirection) {
        _pulseScale += pulseSpeed;
        if (_pulseScale >= 1.0 + pulseRange) {
          _pulseDirection = false;
        }
      } else {
        _pulseScale -= pulseSpeed;
        if (_pulseScale <= 1.0 - pulseRange) {
          _pulseDirection = true;
        }
      }
      
      notifyListeners();
    });
  }

  void _stopPulseAnimation() {
    _pulseTimer?.cancel();
    _pulseScale = 1.0;
  }

  void _checkCountdownCondition() {
    final currentFingerCount = _activeFingers.length;
    
    if (currentFingerCount >= 2 && _gameState == GameState.waiting) {
      _startCountdown();
      _previousFingerCount = currentFingerCount;
    } else if (currentFingerCount >= 2 && _gameState == GameState.countdown) {
      // Always reset countdown when finger count changes during active countdown
      // This ensures any finger addition or removal resets the timer
      if (currentFingerCount != _previousFingerCount) {
        _resetCountdown();
        _previousFingerCount = currentFingerCount;
      }
    } else if (currentFingerCount < 2) {
      // Cancel countdown if we drop below 2 fingers, regardless of current state
      if (_gameState == GameState.countdown) {
        _cancelCountdown();
      }
      _previousFingerCount = currentFingerCount;
    } else {
      _previousFingerCount = currentFingerCount;
    }
  }

  void _startCountdown() {
    _gameState = GameState.countdown;
    _remainingSeconds = 3;
    _countdownProgress = 0.0;
    _shouldResetProgress = false;
    
    // Use a higher frequency timer for smooth progress updates
    const totalDuration = Duration(milliseconds: 1200); // 1.5 seconds (25% faster than 2 seconds)
    const updateInterval = Duration(milliseconds: 16); // ~60fps
    final totalSteps = totalDuration.inMilliseconds / updateInterval.inMilliseconds;
    int currentStep = 0;
    
    _countdownTimer = Timer.periodic(updateInterval, (timer) {
      currentStep++;
      _countdownProgress = currentStep / totalSteps;
      
      // Update remaining seconds for any logic that still needs it
      _remainingSeconds = (3 - (_countdownProgress * 3)).ceil();
      
      notifyListeners();
      
      if (_countdownProgress >= 1.0) {
        _selectWinner();
        timer.cancel();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _resetTimer?.cancel(); // Cancel any existing reset timer
    _gameState = GameState.waiting;
    _remainingSeconds = 3;
    _shouldResetProgress = true;
    notifyListeners();
    
    // Reset the flag after animation completes (400ms animation + small buffer)
    _resetTimer = Timer(const Duration(milliseconds: 450), () {
      _shouldResetProgress = false;
      _countdownProgress = 0.0;
      _resetTimer = null;
      notifyListeners();
    });
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    _resetTimer?.cancel(); // Cancel any existing reset timer
    _remainingSeconds = 3;
    _shouldResetProgress = true;
    notifyListeners();
    
    // Brief delay for reset animation, then start new countdown
    _resetTimer = Timer(const Duration(milliseconds: 450), () {
      if (_gameState == GameState.countdown) { // Only restart if still in countdown state
        _shouldResetProgress = false;
        _countdownProgress = 0.0;
        _resetTimer = null;
        _startCountdown();
      } else {
        // If state changed during reset, ensure we clean up
        _shouldResetProgress = false;
        _countdownProgress = 0.0;
        _resetTimer = null;
        notifyListeners();
      }
    });
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
        _isInWinnerDisplayMode = true;
        notifyListeners();
        
        // Start timer to keep winner displayed for 3 seconds
        _winnerDisplayTimer = Timer(const Duration(seconds: 3), () {
          _isInWinnerDisplayMode = false;
          _resetGame();
        });
      }
    });
  }

  void _resetGame() {
    _countdownTimer?.cancel();
    _resetTimer?.cancel(); // Cancel any existing reset timer
    _winnerDisplayTimer?.cancel(); // Cancel winner display timer
    _stopPulseAnimation();
    _activeFingers.clear();
    _gameState = GameState.waiting;
    _remainingSeconds = 3;
    _countdownProgress = 0.0;
    _shouldResetProgress = false;
    _winner = null;
    _winnerBackgroundColor = null;
    _winnerCircleScale = 1.0;
    _colorIndex = 0;
    _previousFingerCount = 0;
    _isInWinnerDisplayMode = false;
    notifyListeners();
  }

  void onProgressResetComplete() {
    _shouldResetProgress = false;
    _countdownProgress = 0.0;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Clear all tracked fingers when app goes to background or becomes inactive
    // This prevents ghost fingers from edge gestures when app is reopened
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _clearAllFingers();
    }
  }

  void _clearAllFingers() {
    if (_activeFingers.isNotEmpty) {
      _activeFingers.clear();
      _cancelCountdown();
      _stopPulseAnimation();
      _gameState = GameState.waiting;
      _previousFingerCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _resetTimer?.cancel();
    _winnerDisplayTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }
}
