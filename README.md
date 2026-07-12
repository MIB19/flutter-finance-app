# keuangan-app

Flutter (Android) client for the family finance tracker. Talks to `keuangan-server`.

## Prerequisites (manual, one-time)

1. **Supabase**: create a project, enable the **Google** auth provider.
2. **Google Cloud OAuth**: create a **Web** client ID (used as `serverClientId`) and an
   **Android** client ID with the app's SHA-1 (`keytool -list -v -keystore ~/.android/debug.keystore`).
   applicationId is `com.finance.ivan`.
3. Put the Supabase Google provider's client ID/secret into Supabase.

## Config

Copy `.env.example` to `.env` and fill in your values (`.env` is gitignored):

```
API_BASE_URL=http://10.0.2.2:4000
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

Loaded at startup via `flutter_dotenv` (`.env` is declared as an asset in `pubspec.yaml`).

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

## Screens

Login (Google) → Onboarding (join via code / continue solo) → Main shell
(Home = balance + month list + month picker + add; Tetap = recurring rules; Keluarga = invite code + members + logout).
