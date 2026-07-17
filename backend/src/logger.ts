import type { RequestHandler } from 'express';

export type LogFn = (message: string) => void;

// one line per request, logged on finish so the status code is known
export function requestLogger(log: LogFn): RequestHandler {
  return (req, res, next) => {
    const start = process.hrtime.bigint();
    res.on('finish', () => {
      const ms = Number(process.hrtime.bigint() - start) / 1e6;
      log(`${req.method} ${req.originalUrl} ${res.statusCode} ${ms.toFixed(1)}ms`);
    });
    next();
  };
}
