# Backend

Node + TypeScript API. Verifies the Firebase ID token and does the math.

## Run

```bash
npm install
npm run dev        # http://localhost:3000
```

Scripts: `npm run typecheck`, `npm test`, `npm run build && npm start`.

`PORT` overrides the port, but only if you export it. There is no `dotenv` here,
so a `.env` file is read by nothing:

```bash
PORT=4000 npm run dev
```

## Logs

One line per request, so you can see the app hitting the backend:

```
GET /health 200 1.6ms
POST /api/calculate 401 0.3ms
GET /nope 404 0.4ms
```

Failed token checks also log the underlying reason, since a bad token and an
unreachable admin SDK both return the same 401.

## Endpoints

### `GET /health`
No auth. Returns `{ "status": "ok" }`.

### `POST /api/calculate`
Needs `Authorization: Bearer <firebaseIdToken>`.

Body:
```json
{ "operation": "add" | "subtract" | "multiply", "a": 6, "b": 7 }
```

Returns:
```json
{ "operation": "multiply", "a": 6, "b": 7, "result": 42 }
```

- `400` if the operation is unknown or `a`/`b` aren't numbers.
- `401` if the token is missing or invalid.

## Testing

```bash
npm test
```

Covers the math (add/subtract/multiply), the validation (bad op, non-numbers),
and the auth guard (401 without a token). The auth middleware is stubbed in the
route tests so they run without credentials.

Quick manual check:

```bash
npm run dev
curl localhost:3000/health
curl -X POST localhost:3000/api/calculate -H 'Content-Type: application/json' \
  -d '{"operation":"add","a":2,"b":3}'   # 401, no token
```

## Firebase credentials

Picked automatically at startup:

1. Service account — set `GOOGLE_APPLICATION_CREDENTIALS`, or drop a
   `serviceAccountKey.json` here (Firebase console → Project settings →
   Service accounts → Generate new private key).
2. Project id only — the fallback. Enough to verify tokens, good for local dev.
