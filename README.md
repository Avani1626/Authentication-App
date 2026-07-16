# Authentication App

A small Flutter app with email/password auth and a calculator that runs its
math on a Node backend.

- **mobile/** — Flutter (dark theme). Firebase auth, calculator UI.
- **backend/** — Node + TypeScript API. Verifies the Firebase token, does the math.

## Run

```bash
cd backend && npm install && npm run dev   # http://localhost:3000
cd mobile && flutter pub get && flutter run
```
