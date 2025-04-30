# DojoDex App

## Overview

This project is a Flutter application that follows a structured file architecture to maintain clean and scalable code. The application uses the BLoC pattern for state management and includes various features and utilities to support the development process.

## Features

- **Blocs**: State management using the BLoC pattern.
- **Common**: Contains styles, services, routes, models, extensions, constants, architectures, utilities, and shared widgets.
- **Data**: Manages local database interactions and repositories to call APIs.
- **Features**: Contains the main screens of the application.
- **Dependencies**
  - **app_dependency_provider**: Provides dependencies at a higher tree level of the app.
  - **authenticated_dependency_provider**: Wraps high tree level widgets and manages disposable BLoCs when logging out.

# Commands

- Clean the build runner
  `flutter pub run build_runner clean`
- Run build runner to generate code and delete conflict
  `flutter pub run build_runner build --delete-conflicting-outputs`
