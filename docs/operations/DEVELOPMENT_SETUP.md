# Shared development setup

Start from `develop` after accepting the GitHub repository invitation. Find your workspace number and plan in the [team guide](../../WORK_DISTRIBUTION.md).

## Team services

- Supabase project `idptcxheihiakwttvkgo` (`elora-dev`), Mumbai/ap-south-1: development PostgreSQL only.
- Firebase project `elora-dev-9f6b9`: email/Google identity.
- Each developer runs FastAPI locally. Cloud Run, branch previews and cloud image storage are follow-up work. The SRS describes the intended deployment.
- The shared `integration` workspace and personal `dev1`–`dev5` workspaces use separate schemas and roles. Flutter calls FastAPI. Keep these schemas out of Supabase's exposed Data API schemas.
- Supabase's free limits/pausing apply; use synthetic data. No paid upgrade is implicit.
- No local Docker, PostgreSQL, Supabase CLI or Firebase CLI is required.

## 1. Install and clone

| Install | What to use |
| --- | --- |
| Git | Git with access to the team's repository. Clone over HTTPS. |
| Python | Python 3.12, with `pip` and `venv`. On Windows install the Python launcher so `py -3.12` selects the right version. |
| Flutter | Flutter 3.47.5 stable with bundled Dart 3.13.4, matching CI. Add Flutter's `bin` directory to PATH. [Flutter SDK archive](https://docs.flutter.dev/install/archive) |
| Android tools | Android Studio or an existing Android SDK with SDK Platform, Build-Tools, Platform-Tools and Command-line Tools. Install an emulator system image or enable USB debugging on a phone. Use JDK 17 for the CI-matched setup. [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup) |

Run these in a terminal. Resolve the Android toolchain issues that `flutter doctor` reports and make sure `flutter devices` can see your emulator or phone.

```powershell
git clone -b develop https://github.com/Tenzrr/Elora.git
cd Elora
git --version
py -3.12 --version
flutter --version
flutter doctor --android-licenses
flutter doctor -v
flutter devices
```

On macOS or Linux, use `python3.12` in place of `py -3.12`.

## 2. Send the project owner your Android debug SHA-1

Firebase uses the debug signing **certificate fingerprint** for Google sign-in on the shared Android app `app.elora.elora_mobile`. In a terminal at the repository root, build once to generate the standard debug keystore if one does not exist, then print the signing report.

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter build apk --debug
cd android
.\gradlew.bat signingReport
```

On macOS or Linux use `./gradlew signingReport` inside `mobile/android`. Under **Variant: debug**, copy the line labelled **SHA1**. If the report says the keystore is missing, finish the debug build and run the report again.

Privately message **Athauda K. G. (Dev 1)** your developer number, GitHub username, and the SHA-1 fingerprint for each machine you will build on. Send the fingerprint as text, with its colon separators. Keep the keystore, private keys, and configuration files on your machine. If your debug keystore changes, send the new fingerprint. Dev 1 registers it and gives you the shared app configuration described below. [Firebase Android fingerprint instructions](https://firebase.google.com/codelabs/firebase-auth-in-flutter-apps)

## 3. Configure your workspace and run the app

Get these files privately from Dev 1 and place them relative to the repository root.

| File | Purpose |
| --- | --- |
| `.secrets/devN.json` | Your scoped Supabase connection. Replace `N` with your assigned number. |
| `.secrets/firebase-admin.json` | Your assigned development credential for the **backend** to verify Firebase accounts. Keep it out of `mobile/`. |
| `mobile/config/dev.json` | Development Android app and Google sign-in configuration used by `flutter run`. |

Open a new terminal at the repository root. The example uses Dev 1's workspace number. Use your own.

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python -m pip install --require-hashes -r backend/requirements.lock
.\.venv\Scripts\python backend/tools/configure_cloud.py --runtime dev1
.\.venv\Scripts\python -m uvicorn app.main:app --app-dir backend --reload
```

On macOS or Linux use `python3.12 -m venv .venv` and replace `.\.venv\Scripts\python` with `.venv/bin/python`. The configuration tool creates an ignored root `.env` and preserves it on rerun. If your assigned credentials change, move the old file out of the repository before regenerating it. No shell activation is needed.

In a second terminal, check `http://localhost:8000/health`, then launch Android from the repository root.

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter run --dart-define-from-file=config/dev.json
```

- **Emulator.** Use `http://10.0.2.2:8000` for `API_BASE_URL` in `mobile/config/dev.json`.
- **Physical phone.** Use your computer's reachable LAN address and port 8000, and append `--host 0.0.0.0` when starting Uvicorn on a trusted network.
- **Confirm your connection.** Use **Continue with Google** with a development test account to verify the registered SHA-1. Open My Garden, add a synthetic test plant, restart the app, confirm it loads, then delete it. Tell Dev 1 which workspace and device you verified. If you get stuck, share the error and failed step with credentials removed. A healthy `/health` response checks the local server. The sign-in and plant check exercises Firebase and your assigned database.

## Coordinator: Supabase and Firebase

1. Create the Free Supabase project. Save its database password privately. In Connect select **Session pooler, port 5432**; don't use the transaction pooler or guess its hostname.
   Download the public server CA through Database Settings to `backend/certs/supabase-root.crt`. The client keeps certificate/hostname verification enabled. This public trust anchor can be reviewed and committed; it is not a private key.
2. Create the Firebase development project. Enable Authentication > Email/Password and Google. Add Android app package `app.elora.elora_mobile`.
3. In Firebase **Project settings → General → Your apps**, select `app.elora.elora_mobile` and add each submitted debug SHA-1 under **SHA certificate fingerprints**. Confirm registration with the developer. Firebase console access is a separate permission.
4. Download the updated Android `google-services.json` to `mobile/android/app/google-services.json` (ignored). Firebase client configuration is not an Admin SDK private key.
5. Run `python backend/tools/configure_cloud.py`. It uses standard Python, prompts for the database password without echoing it, and writes ignored coordinator/client files. It refuses to overwrite existing files.
6. For backend token-revocation checks, use development-only Google credentials. Create a dedicated service account in the development project's IAM console with **Firebase Authentication Viewer**; save its JSON key privately as `.secrets/firebase-admin.json`. Do not use an Owner credential or share a production key. Hosted services later use their service identity instead of JSON keys. For ordinary developers use individually revocable scoped credentials.
7. Install backend dependencies in a Python virtual environment using the locked file below.
8. Provision `integration` and `dev1`–`dev5` individually with `python backend/tools/workspace.py create dev1 --output .secrets/dev1.json`; then `python backend/tools/migrate.py dev1`. Repeat with each workspace name. Only the coordinator/CI needs the admin URL.
9. Application tables stay in these private schemas, outside Supabase's exposed schemas. Do not enable Data API exposure for them. Preserve existing provider-owned schemas.
10. Give each person only their scoped workspace file, development client configuration and development credential through a private channel. Never commit `.env`, `.env.coordinator`, `.secrets/` or downloaded private keys.

## Contracts and verification

The foundation implements Firebase session/profile and owned plant CRUD, not crop inference, chat, weather or community workflows. Shared UI is a foundation workspace, not the final PNG-matched product garden/plant presentation. Feature owners extend it against the approved references. Crop identifiers are canonical API slugs; language translations are a starting draft requiring human review.

`python -m pytest` runs cloud-free tests. PostgreSQL integration runs in CI with a disposable PostgreSQL/pgvector service, checking migrations and runtime role isolation. Set TEST_DATABASE_URL only for a disposable CI database, never the shared hosted project. `flutter analyze`, `flutter test` and `flutter build apk --debug` verify Android without credentials; missing configuration shows a setup screen.

Keep TLS verification enabled for Supabase. The coordinator applies reviewed Alembic revisions to the shared integration schema. Developers have access to their assigned workspaces. Historical Compose and initialization SQL live under `docs/archive/`.

The current plant workspace lists the first 100 owned records. The API provides cursor pagination for the complete feature UI. Private profile/plant providers reset on authentication changes. No crop model or percentage is reported as trained/completed.

References: [Supabase connections](https://supabase.com/docs/guides/database/connecting-to-postgres), [Firebase Flutter auth](https://firebase.google.com/docs/auth/flutter/start), [Firebase token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens).
