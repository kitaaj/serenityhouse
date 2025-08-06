# Mental Health Support App

A Flutter application for mental health support with offline-first architecture using Brick and Supabase.

## Features

- **User Authentication**: Secure login and registration with Supabase
- **Mood Tracking**: Record and visualize your mood patterns
- **Journaling**: Write and manage journal entries
- **AI Chat Support**: Get support through AI-powered conversations

## Architecture

This application uses:

- **Flutter**: UI framework
- **Firebase**: Backend
- **BLoC Pattern**: State management
- **Material 3**: Modern UI design

## Getting Started

### Prerequisites

- Flutter SDK (with Dart 3.3.1 or compatible)
- Firebase account
- RECAPTCHA_V3_SITE_KEY
- Gemini API key (for AI chat)

### Installation

1. Clone the repository
2. Create a `.env` file in the root directory with:
   ```
   RECAPTCHA_V3_SITE_KEY = your_recaptcha_v3_site_key
   GEMINI_API_KEY=your_gemini_api_key
   ```
3. Run the following commands:
   ```
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run
   ```



## Project Structure

- `lib/models/`: Data models with Brick annotations
- `lib/screens/`: UI screens organized by feature
- `lib/services/`: Business logic and services
- `lib/widgets/`: Reusable UI components
- `lib/theme/`: App theme configuration
- `lib/utilities/`: Helper functions and utilities

## Dependencies

- `flutter_bloc`: State management
- `google_generative_ai`: Gemini AI integration
- See `pubspec.yaml` for the complete list

