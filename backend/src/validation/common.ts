import { z } from 'zod';

export const emailSchema = z.string().trim().toLowerCase().email().max(254);
export const passwordSchema = z.string().min(12).max(128)
  .regex(/[a-z]/, 'Password must include a lowercase letter.')
  .regex(/[A-Z]/, 'Password must include an uppercase letter.')
  .regex(/[0-9]/, 'Password must include a number.');
export const assetIdSchema = z.string().trim().min(1).max(128).regex(/^[a-z0-9-]+$/);
export const cursorSchema = z.string().datetime().optional();
export const pageSizeSchema = z.coerce.number().int().min(1).max(50).default(20);
