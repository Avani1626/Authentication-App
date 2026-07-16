export type Operation = 'add' | 'subtract' | 'multiply';

const OPERATIONS: Operation[] = ['add', 'subtract', 'multiply'];

export function isOperation(value: unknown): value is Operation {
  return typeof value === 'string' && (OPERATIONS as string[]).includes(value);
}

export function calculate(operation: Operation, a: number, b: number): number {
  switch (operation) {
    case 'add':
      return a + b;
    case 'subtract':
      return a - b;
    case 'multiply':
      return a * b;
  }
}
