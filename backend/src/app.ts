import express from 'express';
import cors from 'cors';
import { calculate, isOperation } from './calculate.js';
import { verifyToken } from './firebase.js';
import { requestLogger, type LogFn } from './logger.js';

export function createApp(log: LogFn = console.log) {
  const app = express();
  // first, so 400s and 401s get logged too
  app.use(requestLogger(log));
  app.use(cors());
  app.use(express.json());

  app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
  });

  app.post('/api/calculate', verifyToken, (req, res) => {
    const { operation, a, b } = req.body ?? {};
    if (!isOperation(operation)) {
      res.status(400).json({ error: 'bad operation' });
      return;
    }
    if (typeof a !== 'number' || !Number.isFinite(a) || typeof b !== 'number' || !Number.isFinite(b)) {
      res.status(400).json({ error: 'a and b must be numbers' });
      return;
    }
    res.json({ operation, a, b, result: calculate(operation, a, b) });
  });

  return app;
}
