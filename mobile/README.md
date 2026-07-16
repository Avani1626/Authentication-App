# Mobile

Flutter app, dark theme. Firebase email/password auth and a calculator that
calls the backend.

## Screens

- **Login / Sign up** — email + password. Sign up enforces a strong password
  (6+ chars, an uppercase, a number, a special char).
- **Verify email** — after sign up, Firebase emails a verification link. The
  calculator stays locked until the email is verified. This screen auto-checks
  every few seconds and has a resend button.
- **Calculator** — two numbers, add / subtract / multiply. The math runs on the
  backend, which verifies the login first.

## Run

```bash
flutter pub get
flutter run
```

Start the backend first (see `../backend`), and enable Email/Password in the
Firebase console (Authentication → Sign-in method).

## Backend URL

`baseUrl` is at the top of `lib/services/api_service.dart`.

- Android emulator: `http://10.0.2.2:3000` (the default here).
- Web / iOS simulator: `http://localhost:3000`.
- Physical device: your computer's LAN IP, e.g. `http://192.168.1.42:3000`.

## Testing the flow

1. Sign up with a real email you can open.
2. Click the link in your inbox. The verify screen moves on by itself.
3. Enter two numbers, tap Add / Subtract / Multiply, check the result.
4. Sign out from the calculator app bar and sign back in.

`flutter analyze` should report no issues.

## Real device builds

Android and iOS need their own Firebase files (`google-services.json` /
`GoogleService-Info.plist`) from the Firebase console, or run
`flutterfire configure` to regenerate `firebase_options.dart`. The bundled
config has the web app wired up.
