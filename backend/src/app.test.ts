import { describe, it, expect, vi } from 'vitest';
import request from 'supertest';

// stub auth: accept any Bearer token, 401 otherwise
vi.mock('./firebase.js', () => ({
  verifyToken: (req: any, res: any, next: any) => {
    if ((req.header('authorization') ?? '').startsWith('Bearer ')) return next();
    res.status(401).json({ error: 'missing token' });
  },
}));

const { createApp } = await import('./app.js');
const app = createApp(() => {});
const auth = { Authorization: 'Bearer test' };

describe('GET /health', () => {
  it('returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});

describe('POST /api/calculate', () => {
  it('adds', async () => {
    const res = await request(app).post('/api/calculate').set(auth).send({ operation: 'add', a: 2, b: 3 });
    expect(res.status).toBe(200);
    expect(res.body.result).toBe(5);
  });

  it('rejects a bad operation', async () => {
    const res = await request(app).post('/api/calculate').set(auth).send({ operation: 'divide', a: 6, b: 2 });
    expect(res.status).toBe(400);
  });

  it('rejects non-numbers', async () => {
    const res = await request(app).post('/api/calculate').set(auth).send({ operation: 'add', a: 'x', b: 3 });
    expect(res.status).toBe(400);
  });

  it('needs a token', async () => {
    const res = await request(app).post('/api/calculate').send({ operation: 'add', a: 1, b: 1 });
    expect(res.status).toBe(401);
  });
});
