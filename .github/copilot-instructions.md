<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Finger Picker App - Copilot Instructions

This is a Flutter project for a multi-platform finger selection app with the following key features:

## Project Structure
- **lib/main.dart**: App entry point with Provider setup
- **lib/screens/game_screen.dart**: Main game interface with touch detection
- **lib/services/game_logic.dart**: Core game logic and state management
- **lib/models/finger_data.dart**: Data model for tracked fingers
- **lib/widgets/**: Reusable UI components (circle painter, countdown timer)
- **lib/utils/**: Utility classes (color generator)

## Key Technologies
- Flutter with Provider for state management
- Custom painting for smooth circle animations
- Multi-touch gesture detection using Listener widget
- Timer-based countdown system

## Code Guidelines
- Use Provider pattern for state management
- Implement smooth 60fps animations
- Follow Flutter best practices for performance
- Use proper null safety
- Maintain clean separation of concerns between UI and business logic

## Core Features
1. Multi-touch tracking with colored circles
2. 5-second countdown timer when 2+ fingers detected
3. Random winner selection with fullscreen color animation
4. Smooth entry/exit animations for finger circles
5. Reset functionality for new rounds

When making changes, prioritize performance and smooth animations while maintaining code readability.
