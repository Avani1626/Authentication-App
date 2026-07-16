import { describe, it, expect } from 'vitest';
import { calculate, isOperation } from './calculate.js';

describe('calculate', () => {
  it('adds', () => expect(calculate('add', 2, 3)).toBe(5));
  it('subtracts', () => expect(calculate('subtract', 10, 4)).toBe(6));
  it('multiplies', () => expect(calculate('multiply', 6, 7)).toBe(42));
});

describe('isOperation', () => {
  it('accepts known ops', () => expect(isOperation('add')).toBe(true));
  it('rejects others', () => {
    expect(isOperation('divide')).toBe(false);
    expect(isOperation(42)).toBe(false);
  });
});
