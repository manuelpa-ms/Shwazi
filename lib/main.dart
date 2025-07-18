import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/game_screen.dart';
import 'services/game_logic.dart';

void main() {
  runApp(const FingerPickerApp());
}

class FingerPickerApp extends StatelessWidget {
  const FingerPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameLogic(),
      child: MaterialApp(
        title: 'Finger Picker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
