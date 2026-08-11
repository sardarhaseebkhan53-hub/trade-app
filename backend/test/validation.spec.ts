import { describe, expect, it } from 'vitest';

import { parse } from '../src/middleware/validate.js';
import { createAlertSchema, registerSchema } from '../src/validation/schemas.js';

describe('input validation', () => {
  it('rejects malformed registration payloads', () => {
    expect(() => parse(registerSchema, { name: 'A', email: 'not-an-email', password: 'short' })).toThrow();
  });

  it('rejects non-positive or malformed alert prices', () => {
    expect(() => parse(createAlertSchema, { assetId: '../bitcoin', condition: 'ABOVE', targetPrice: -1 })).toThrow();
  });
});
