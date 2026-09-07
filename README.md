# Sénat Social App UI

The cross-platform client for Sénat Social App, built with Flutter and Dart.

## Features

- registration, login, email verification, and password recovery;
- a social feed with media, comments, reactions, and search;
- user profiles, user search, and settings;
- real-time private messaging with image and video sharing;
- individual audio/video calls and WebRTC group calls;
- meetings and live/TV streaming;
- call notifications, light/dark themes, and responsive layouts.

## Technologies

- Flutter and Dart (`sdk >= 3.8.1`);
- Riverpod, Provider, and GoRouter;
- Dio for HTTP requests and Socket.IO for real-time communication;
- WebRTC, video_player, Chewie, and Media Kit for media;
- flutter_dotenv for environment configuration.

## Requirements

- Flutter installed and available in `PATH`;
- a device or emulator compatible with the selected target;
- an accessible API for connected features.

Check the Flutter installation:

```bash
flutter doctor
```

## Installation

From the `ui/` directory:

```bash
flutter pub get
```

The `ui/.env` file is loaded at startup and must contain:

```dotenv
ENV=dev
HOST=localhost
HOST_PROD=example.com
```

In `dev` mode, the client builds its endpoints using `HOST` and port `4000`.
In production, it uses `https://HOST_PROD` and `wss://HOST_PROD`.

On a physical device, `HOST` must be the IP address of the machine hosting the
server, not `localhost`. Do not put secrets in this file.

## Run the application

```bash
flutter devices
flutter run -d <device-id>
```

The project includes Android, iOS, Windows, macOS, Linux, and Web targets.
WebRTC calls, notifications, and video playback may depend on the selected
platform's capabilities.

## Tests and analysis

```bash
flutter analyze
flutter test
```

## Project structure

```text
lib/
  constant/       Client constants and configuration
  models/         Data models
  providers/      Application state and Socket.IO connection
  routes/         Application routing
  screens/        Auth, posts, messages, profile, meetings, and TV screens
  services/       HTTP, calls, live, and post services
  responsive/     Mobile and desktop layouts
  theme/          Application themes
  utils/          Notifications, startup, and video playback utilities
```

Application assets are declared in `pubspec.yaml`, including
`assets/images/`, `assets/logos/`, and `.env`.

## Related project

The client communicates with the server project: [API README](../api/README.md).

## Documentation

- [Flutter documentation](https://docs.flutter.dev/)
- [Dart documentation](https://dart.dev/docs)
- [flutter_webrtc documentation](https://pub.dev/packages/flutter_webrtc)
