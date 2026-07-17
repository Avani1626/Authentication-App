import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import admin from 'firebase-admin';
import type { NextFunction, Request, Response } from 'express';

const PROJECT_ID = 'test-project-3ea7d';

function initAdmin() {
  if (admin.apps.length) return;
  const keyPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS ?? resolve(process.cwd(), 'serviceAccountKey.json');
  if (existsSync(keyPath)) {
    admin.initializeApp({ credential: admin.credential.cert(keyPath) });
  } else {
    // projectId is enough to verify id tokens
    admin.initializeApp({ projectId: PROJECT_ID });
  }
}

initAdmin();

export async function verifyToken(req: Request, res: Response, next: NextFunction) {
  const match = (req.header('authorization') ?? '').match(/^Bearer (.+)$/i);
  if (!match) {
    res.status(401).json({ error: 'missing token' });
    return;
  }
  try {
    const decoded = await admin.auth().verifyIdToken(match[1]);
    req.uid = decoded.uid;
    next();
  } catch (err) {
    // surface the real reason: a bad token and an unreachable admin SDK both land here
    console.warn(`token verification failed: ${err instanceof Error ? err.message : String(err)}`);
    res.status(401).json({ error: 'invalid token' });
  }
}
