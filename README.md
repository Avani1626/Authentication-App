# Authentication App

A Flutter app with Firebase email/password auth and a calculator whose math runs
on a small Node backend. You sign up, verify your email, then add / subtract /
multiply two numbers. The numbers go to the backend, which checks your login
before doing the math.

## How it works

```
Flutter app  --email/password-->  Firebase Auth  -->  ID token
     |
     |  POST /api/calculate  (Authorization: Bearer <token>)
     v
Node backend  --verify token-->  do the math  -->  { result }
```

- The app never trusts itself with "who are you". Firebase hands it a signed
  token, and the backend verifies that token before answering.
- Email must be verified before the calculator opens.

## Layout

- `mobile/` — Flutter app (dark theme). Auth screens + calculator. See its README.
- `backend/` — Node + TypeScript API. Verifies the token, does the math. See its README.

## Run it on Android

The backend and the app run at the same time, so you need two terminals.

### 0. Once per machine

- Flutter, Node 20+, and Android Studio (for the SDK and an emulator).
  `flutter doctor` tells you what is missing.
- **`google-services.json`.** It is gitignored and the Android build fails
  without it, with an error that does not say why. You need access to the
  Firebase project to generate it. See `mobile/README.md`.
- **Email/Password enabled** in the Firebase console: Authentication →
  Get started → Sign-in method → Email/Password → Enable. Until that is on,
  every sign-in fails with `CONFIGURATION_NOT_FOUND`.

### 1. Start an emulator

Android Studio → Device Manager → start a device. Or from the terminal:

```bash
~/Library/Android/sdk/emulator/emulator -avd <name> &   # `emulator -list-avds` to see names
adb devices                                             # wait for: emulator-5554   device
```

### 2. Backend (terminal 1, leave it running)

```bash
cd backend
npm install
npm run dev
```

Wait for `listening on http://localhost:3000`. This blocks, so leave it alone
and open a second terminal for the app.

### 3. App (terminal 2)

```bash
cd mobile
flutter pub get
flutter run -d emulator-5554        # `flutter devices` for the id
```

The emulator reaches the backend at `10.0.2.2:3000`, which is already the
default. On a physical device you have to change `baseUrl` to your LAN IP, see
`mobile/README.md`.

### 4. Use it

1. **Sign up** with a real email you can open. The password needs 6+ chars, an
   uppercase, a number, and a special char.
2. **Verify email**: click the link in your inbox. The screen moves on by itself.
3. **Calculator**: two numbers, tap Add / Subtract / Multiply. Terminal 1 should
   log `POST /api/calculate 200`. That line means the backend actually verified
   your token, not just that the UI drew a number.
4. **Sign out** from the app bar, sign back in.
5. Sign out again and try **Continue with Google**. It goes straight to the
   calculator, skipping verification, because Google already verified the email.

### If the install fails

`INSTALL_FAILED_INSUFFICIENT_STORAGE` means the emulator is full. The debug APK
is ~140MB. Either uninstall old builds, or give the emulator a bigger disk by
raising `disk.dataPartition.size` in `~/.android/avd/<name>.avd/config.ini` and
booting once with `-wipe-data`. The size only applies when the partition is
created, so without the wipe nothing changes.

## Testing

- Backend: `cd backend && npm test` (unit + route tests).
- App: `cd mobile && flutter analyze`, then walk the flow above.

Full steps are in each folder's README.
