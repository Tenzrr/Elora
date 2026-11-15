# Shared development setup

Foundation branch: `chore/shared-development-foundation`. This is shared preparation, not individual interim feature completion. The finalized SRS is unchanged.

## Team services

- Supabase project `idptcxheihiakwttvkgo` (`elora-dev`), Mumbai/ap-south-1: development PostgreSQL only.
- Firebase project `elora-dev-9f6b9`: email/Google identity.
- Cloud SQL remains the intended deployment database in the SRS. No production environment is created here.
- Integration, dev1–dev5 and PR previews use separate schemas and roles. Application data is not exposed through Supabase's Data API. Flutter always calls FastAPI.
- Supabase's free limits/pausing apply; use synthetic data. No paid upgrade is implicit.
- All five developers need Git, Flutter 3.47.5/Dart 3.13.4 and Python 3.12. No local Docker, PostgreSQL, Supabase CLI or Firebase CLI is required.

## Coordinator: Supabase and Firebase

1. Create the Free Supabase project. Save its database password privately. In Connect select **Session pooler, port 5432**; don't use the transaction pooler or guess its hostname.
   Download the public server CA through Database Settings to `backend/certs/supabase-root.crt`. The client keeps certificate/hostname verification enabled. This public trust anchor can be reviewed and committed; it is not a private key.
2. Create the Firebase development project. Enable Authentication > Email/Password and Google. Add Android app package `app.elora.elora_mobile`.
3. Add each developer's debug SHA-1 to that same app. For this machine: `C5:27:D4:06:34:06:73:64:12:84:BF:4E:09:2A:51:29:D7:29:62:99`. Get another machine's value with `keytool -list -v -keystore <user-home>/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`.
4. Download the updated Android `google-services.json` to `mobile/android/app/google-services.json` (ignored). Firebase client configuration is not an Admin SDK private key.
5. Run `python backend/tools/configure_cloud.py`. It uses standard Python, prompts for the database password without echoing it, and writes ignored coordinator/client files. It refuses to overwrite existing files.
6. For backend token-revocation checks, use development-only Google credentials. Create a dedicated service account in the development project's IAM console with **Firebase Authentication Viewer**; save its JSON key privately as `.secrets/firebase-admin.json`. Do not use an Owner credential or share a production key. Hosted services later use their service identity instead of JSON keys. For ordinary developers use individually revocable scoped credentials.
7. Install backend dependencies in a Python virtual environment using the locked file below.
8. Provision `integration` and `dev1`–`dev5` individually with `python backend/tools/workspace.py create dev1 --output .secrets/dev1.json`; then `python backend/tools/migrate.py dev1`. Repeat with each workspace name. Only the coordinator/CI needs the admin URL.
9. Application tables stay in these private schemas, outside Supabase's exposed schemas. Do not enable Data API exposure for them. Preserve existing provider-owned schemas.
10. Give each person only their scoped workspace file, development client configuration and development credential through a private channel. Never commit `.env`, `.env.coordinator`, `.secrets/` or downloaded private keys.

## Each developer

PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install --require-hashes -r backend/requirements.lock
# Receive .secrets/devN.json, .secrets/firebase-admin.json and mobile/config/dev.json privately.
.\.venv\Scripts\python backend/tools/configure_cloud.py --runtime dev1
.\.venv\Scripts\python -m uvicorn app.main:app --app-dir backend --reload
```

Replace dev1 with your assigned number. For POSIX use `python3 -m venv .venv`, `.venv/bin/python` and the same arguments. No shell activation is needed.

From `mobile/`:

```powershell
flutter pub get --enforce-lockfile
flutter run --dart-define-from-file=config/dev.json
```

The config's API_BASE_URL is the API **origin**, without /api/v1. Android emulator uses `http://10.0.2.2:8000`; a phone uses the computer's reachable LAN address (bind Uvicorn to 0.0.0.0 for that explicit development use). Integration/preview configurations use their HTTPS origin. Never place a database password or server credential in Flutter configuration.

## Contracts and verification

The foundation implements Firebase session/profile and owned plant CRUD, not crop inference, chat, weather or community workflows. Shared UI is a foundation workspace, not the final PNG-matched product garden/plant presentation. Feature owners extend it against the approved references. Crop identifiers are canonical API slugs; language translations are a starting draft requiring human review.

`python -m pytest` runs cloud-free tests. PostgreSQL integration runs in CI with a disposable PostgreSQL/pgvector service, checking migrations and runtime role isolation. Set TEST_DATABASE_URL only for a disposable CI database, never the shared hosted project. `flutter analyze`, `flutter test` and `flutter build apk --debug` verify Android without credentials; missing configuration shows a setup screen.

Do not set DATABASE_REQUIRE_TLS=false for Supabase; that switch is test-only. Schema changes are Alembic revisions, reviewed and serialized at deployment. Developers cannot reset integration/other schemas. Legacy Compose/init SQL is preserved under `docs/archive/`; existing volumes/public tables are untouched and are not automatically imported.

The current plant workspace lists the first 100 owned records. The API provides cursor pagination for the complete feature UI. Private profile/plant providers reset on authentication changes. No crop model or percentage is reported as trained/completed.

## Costs and cloud rollout

Cloud Run integration/previews, a private image bucket, builds/artifacts and secrets are prepared separately. Before provisioning, approve an itemized estimate and billing/account ownership. Preview services scale to zero and are capped/expired, but this does not impose a billing hard cap. The cloud workflows stay disabled until configuration and cost approval are recorded.

References: [Supabase connections](https://supabase.com/docs/guides/database/connecting-to-postgres), [Firebase Flutter auth](https://firebase.google.com/docs/auth/flutter/start), [Firebase token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens).
