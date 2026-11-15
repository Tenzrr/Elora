# Elora Android scaffold

Read the [project README](../README.md), [ownership](../WORK_DISTRIBUTION.md) and [interim plan](../docs/project-management/INTERIM_PLAN.md) first.

This cleanup shell only boots the shared theme. It contains no crop inference, authentication or feature workflows. The previous simulated demo and Windows application have been removed.

The scaffold is tested with Flutter 3.47.5 / Dart 3.13.4, matching CI. Use JDK 17 or a compatible newer JDK and an installed Android SDK. Run `flutter doctor -v` and resolve Android setup/licence issues. Commit dependency lockfile updates only after running the checks below.

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter run
```

Select an Android emulator or connected Android phone. The API runs separately; use `http://10.0.2.2:8000` for the host from the Android emulator, or the host's reachable LAN address from a phone. Authentication and configurable feature networking are subsequent foundation work.

The debug APK is for development. Release signing and production transport configuration are not established by a debug build. Do not use the template's debug signing as production signing.
