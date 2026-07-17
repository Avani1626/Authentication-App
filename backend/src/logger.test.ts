import { describe, it, expect } from 'vitest';
import express from 'express';
import request from 'supertest';
import { requestLogger, type LogFn } from './logger.js';

// real app + collected lines, no console spying
function makeApp() {
  const lines: string[] = [];
  const log: LogFn = (message) => lines.push(message);
  const app = express();
  app.use(requestLogger(log));
  app.get('/ok', (_req, res) => {
    res.json({ status: 'ok' });
  });
  app.get('/boom', () => {
    throw new Error('boom');
  });
  return { app, lines };
}

// loose on the timing so it can't be flaky
const MS = '\\d+\\.\\dms$';

describe('requestLogger', () => {
  it('logs method, url and status for a good request', async () => {
    const { app, lines } = makeApp();
    const res = await request(app).get('/ok');
    expect(res.status).toBe(200);
    expect(lines[0]).toMatch(new RegExp(`^GET /ok 200 ${MS}`));
  });

  it('logs the status of a request that 404s', async () => {
    const { app, lines } = makeApp();
    const res = await request(app).get('/nope');
    expect(res.status).toBe(404);
    expect(lines[0]).toMatch(new RegExp(`^GET /nope 404 ${MS}`));
  });

  it('logs the status of a request that throws', async () => {
    const { app, lines } = makeApp();
    const res = await request(app).get('/boom');
    expect(res.status).toBe(500);
    expect(lines[0]).toMatch(new RegExp(`^GET /boom 500 ${MS}`));
  });

  it('logs exactly one line per request', async () => {
    const { app, lines } = makeApp();
    await request(app).get('/ok');
    expect(lines).toHaveLength(1);
    await request(app).get('/nope');
    expect(lines).toHaveLength(2);
  });
});
