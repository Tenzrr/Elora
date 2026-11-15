# Elora Android development

Read the [project README](../README.md), [ownership](../WORK_DISTRIBUTION.md) and [interim plan](../docs/project-management/INTERIM_PLAN.md) first.

The Android foundation provides Firebase sign-in, language selection and a workspace for owned plant records. The five module entry points are reserved for feature development. Follow the [shared setup guide](../docs/operations/DEVELOPMENT_SETUP.md) to obtain your development configuration.

## Building a feature screen

Match the [screen references](../docs/screens) using the [shared theme](lib/core/theme/app_theme.dart). The app bundles Inter from the [official v4.1 release](https://github.com/rsms/inter/releases/tag/v4.1), with its license in `assets/fonts/OFL.txt`.

| Tab | Module | Owner |
| --- | --- | --- |
| Quality | Produce Quality Assessment | Dev 2 |
| Farming | Predictive Farming Analytics | Dev 3 |
| Scan | Crop Health Analysis | Dev 1 |
| Chat | Personalized Agricultural Agent | Dev 4 |
| Community | Community and User Accounts | Dev 5 |

Put your screen in the feature directory listed in [ownership](../WORK_DISTRIBUTION.md) and connect it to its existing route in [the router](lib/main.dart). The [shared shell](lib/core/elora_shell.dart) supplies the header and bottom navigation. Open My Profile from the header to see the [reference screen](lib/screens/profile_screen.dart). Reuse the themed `Card`, `TextFormField`, `FilledButton`, and `OutlinedButton` for cards, forms, and actions. Add new text to all three app localizations.

## Running the app

The scaffold is tested with Flutter 3.47.5 / Dart 3.13.4, matching CI. Use JDK 17 or a compatible newer JDK and an installed Android SDK. Run `flutter doctor -v` and resolve Android setup/licence issues. Commit dependency lockfile updates only after running the checks below.

```powershell
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --debug
flutter run --dart-define-from-file=config/dev.json
```

Select an Android emulator or connected Android phone. Point API_BASE_URL at your local Python API. For an emulator on the same machine, use `http://10.0.2.2:8000`. A physical phone needs the host's reachable LAN address. HTTP is available in debug builds only.

The debug APK is for development. Release signing and production transport configuration are not established by a debug build. Do not use the template's debug signing as production signing.
