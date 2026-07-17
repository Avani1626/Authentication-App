# Mobile

Flutter app, dark theme. Firebase email/password auth and a calculator that
calls the backend.

## Screens

- **Login / Sign up** — email + password. Sign up enforces a strong password
  (6+ chars, an uppercase, a number, a special char). Login also has a
  **Continue with Google** button.
- **Verify email** — after sign up, Firebase emails a verification link. The
  calculator stays locked until the email is verified. This screen auto-checks
  every few seconds and has a resend button. Google accounts skip this, since
  Google has already verified the address.
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
- Web: `http://localhost:3000`.
- Physical device: your computer's LAN IP, e.g. `http://192.168.1.42:3000`.

## Testing the flow

1. Sign up with a real email you can open.
2. Click the link in your inbox. The verify screen moves on by itself.
3. Enter two numbers, tap Add / Subtract / Multiply, check the result.
4. Sign out from the calculator app bar and sign back in.
5. Sign out again and try **Continue with Google**. It should land straight on
   the calculator, skipping the verify screen.

`flutter analyze` should report no issues.

## Google sign-in

Needs the SHA-1 of the keystore that signed the build registered against the
Android app in Firebase. Without it Google sign-in fails at the picker with an
error that does not say why. Debug keystore:

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1

firebase apps:android:sha:create <androidAppId> <sha1> --project authentication-applicati-23e5b
```

Debug keystores are per machine, so every developer has to add their own. After
adding one, re-run `flutterfire configure` to refresh `google-services.json`.

`serverClientId` in `lib/services/auth_service.dart` is the type 3 (web) oauth
client from `google-services.json`. Android needs it to get an id token back.

## Firebase setup (required on a fresh clone)

**The Android build fails on a fresh clone until you do this.**
`android/app/google-services.json` is deliberately gitignored, and the
`com.google.gms.google-services` Gradle plugin refuses to build without it:

```
File google-services.json is missing. The Google Services Plugin cannot function without it.
```

To generate it you need access to the Firebase project
(`authentication-applicati-23e5b`). Then:

```bash
npm install -g firebase-tools
firebase login

dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"

flutterfire configure -p authentication-applicati-23e5b --platforms=android,web -a com.avani.authapp
```

That writes `google-services.json` and regenerates `lib/firebase_options.dart`.
The generated file is committed, so usually only the JSON is missing.

The Android package is `com.avani.authapp`, set in `android/app/build.gradle.kts`
as both `namespace` and `applicationId`. It has to match what is registered in
Firebase, so if you change one, re-run `flutterfire configure`.

Note the app is registered in the Firebase console as `calc_app`, since
flutterfire takes that name from `pubspec.yaml`. It is only a display label.

## iOS

Not configured. `firebase_options.dart` throws `UnsupportedError` on iOS,
because only `android` and `web` have been set up. To add it, register an iOS
app in the console and re-run `flutterfire configure` with `ios` in
`--platforms`.
