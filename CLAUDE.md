# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application named "cnds_app" using Flutter SDK 3.9.2+. It's a reservation management app with Directus backend authentication that displays a product catalog where users can make reservations.

## Development Commands

- **Install dependencies**: `flutter pub get`
- **Upgrade dependencies**: `flutter pub upgrade`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format lib/`
- **Generate JSON serialization**: `dart run build_runner build`
- **Generate app icons**: `flutter pub run flutter_launcher_icons`

## Architecture Overview

The app follows Clean Architecture principles with clear separation of concerns:

### Layer Structure:
- **Models** (`lib/models/`): Data models with JSON serialization (User, Profile, Product, Reservation)
- **Services** (`lib/services/`): External API communication (DirectusService)
- **Repositories** (`lib/repositories/`): Data access abstraction layer
- **Providers** (`lib/providers/`): State management with Provider pattern
- **Screens** (`lib/screens/`): UI layer organized by feature

### Key Files:
- `lib/main.dart`: App entry point with dependency injection setup
- `lib/services/directus_service.dart`: Directus API integration (baseUrl: https://api-cnds-7d4e5a.online404.com)
- `lib/repositories/auth_repository.dart`: Authentication data access
- `lib/repositories/product_repository.dart`: Product data access
- `lib/providers/auth_provider.dart`: Authentication state management
- `lib/providers/product_provider.dart`: Product state management

### Screen Flow:
1. `SplashScreen`: Checks authentication status and redirects accordingly
2. `LoginScreen`/`RegisterScreen`: Authentication flow
3. `EmailVerificationScreen`: Post-registration email verification
4. `ProfileSetupScreen`: Nickname setup for new users
5. `HomeScreen`: Product catalog with 2-column grid and reservation functionality
6. `ProfileScreen`: User profile management with account deletion

## API Integration

- **Backend**: Directus CMS at https://api-cnds-7d4e5a.online404.com
- **Authentication**: JWT tokens with refresh token rotation
- **Collections**: users, profiles, products, reservations
- **Profile requirement**: Users must have a nickname in profiles table to access the app

## Key Dependencies

- **http**: API communication
- **provider**: State management
- **shared_preferences**: Local token storage
- **json_annotation/json_serializable**: JSON serialization
- **build_runner**: Code generation
- **flutter_launcher_icons**: App icon generation
- **flutter_lints**: Code quality

## Development Notes

- Uses Material Design 3 with deep purple color scheme
- Tutoiement (tu/toi) used throughout the French UI
- Private package (publish_to: 'none' in pubspec.yaml)
- All async operations include proper error handling and loading states
- No test suite currently implemented