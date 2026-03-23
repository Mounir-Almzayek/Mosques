# Mosques

Flutter app for mosque display and settings (Firebase, BLoC, GoRouter).

**Repository:** [github.com/Mounir-Almzayek/Mosques](https://github.com/Mounir-Almzayek/Mosques)

## Local setup

- Flutter SDK (see `pubspec.yaml` for Dart constraint).
- Copy `assets/.env` from a secure source if missing (file is gitignored).

## Shorebird (over-the-air updates)

Shorebird CLI is installed separately ([install guide](https://docs.shorebird.dev)). After [creating an account](https://console.shorebird.dev):

1. `shorebird login`
2. From this project root: `shorebird init` (creates `shorebird.yaml` and registers the app; adds the asset to `pubspec.yaml`).
3. `shorebird doctor` to verify tooling.
4. Ship builds with `shorebird release` (not plain `flutter build` for patched releases). Push Dart/asset fixes with `shorebird patch`.

`app_id` in `shorebird.yaml` is not secret and is safe to commit.

## Getting Started (Flutter)

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
