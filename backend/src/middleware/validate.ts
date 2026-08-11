import type { ZodType } from 'zod';

import { AppError } from '../lib/api.js';

export function parse<T>(schema: ZodType<T>, value: unknown): T {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new AppError('VALIDATION_FAILED', 'Please review the submitted information.', 422);
  }
  return result.data;
}
