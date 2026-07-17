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

## Run on Android

You need Android Studio (for the SDK and an emulator) and a JDK. `flutter doctor`
tells you what is missing.

**Emulator**

1. Open Android Studio → Device Manager → create a device (any recent Pixel with
   a Play Store image) and start it.
2. Check Flutter can see it:

   ```bash
   flutter devices
   ```

3. Run:

   ```bash
   flutter run -d emulator-5554        # or the id from `flutter devices`
   ```

The default `baseUrl` is already `http://10.0.2.2:3000`, which is how the
emulator reaches your machine's localhost. Keep the backend running.

**Physical device**

1. On the phone: Settings → About phone → tap Build number 7 times, then
   Developer options → enable USB debugging.
2. Plug it in and accept the debugging prompt.
3. Point `baseUrl` in `lib/services/api_service.dart` at your computer's LAN IP
   (e.g. `http://192.168.1.42:3000`). `10.0.2.2` only works on the emulator, and
   `localhost` on the phone means the phone itself.
4. Run:

   ```bash
   flutter run -d <device-id>
   ```

Both phone and computer must be on the same network. Cleartext HTTP is already
allowed in the debug manifest, so a plain `http://` backend URL is fine.

**APK**

```bash
flutter build apk --debug            # build/app/outputs/flutter-apk/app-debug.apk
flutter install
```

A release APK needs a signing config, which this project does not have yet.

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

## Firebase config caveat

The bundled `firebase_options.dart` was generated from the **web** app
registration, and the `android` block reuses that web `appId`. It is enough for
email/password auth to work on Android, but it is not a real Android
registration. To do it properly, register the Android app
(package name `com.example.calc_app`) in the Firebase console and run:

```bash
flutterfire configure
```

That rewrites `firebase_options.dart` and drops `google-services.json` into
`android/app/`. iOS needs the same treatment with `GoogleService-Info.plist`.
