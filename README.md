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

## Quick start

Run the backend first, then the app.

```bash
cd backend && npm install && npm run dev      # http://localhost:3000
cd mobile  && flutter pub get && flutter run
```

`flutter run` picks whatever device is attached. To target Android, start an
emulator from Android Studio's Device Manager (or plug in a phone with USB
debugging on), then:

```bash
flutter devices                  # find the id
flutter run -d emulator-5554
```

On the emulator the backend is reachable at `10.0.2.2:3000`, which is already
the default. On a physical device you have to change `baseUrl` to your LAN IP.
See `mobile/README.md` for the full walkthrough.

Before signing up, enable Email/Password in the Firebase console:
Authentication → Sign-in method → Email/Password → Enable.

## Testing

- Backend: `cd backend && npm test` (unit + route tests).
- App: `cd mobile && flutter analyze` and run through sign up → verify → calculate.

Full steps are in each folder's README.
