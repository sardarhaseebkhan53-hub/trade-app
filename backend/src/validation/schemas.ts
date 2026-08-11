import { z } from 'zod';

import { assetIdSchema, emailSchema, passwordSchema } from './common.js';

export const registerSchema = z.object({
  name: z.string().trim().min(2).max(80),
  email: emailSchema,
  password: passwordSchema,
  deviceId: z.string().trim().min(1).max(128).optional(),
});
export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1).max(128),
  deviceId: z.string().trim().min(1).max(128).optional(),
});
export const refreshSchema = z.object({ refreshToken: z.string().min(32).max(512) });
export const forgotPasswordSchema = z.object({ email: emailSchema });
export const resetPasswordSchema = z.object({ token: z.string().min(32).max(512), password: passwordSchema });
export const profileSchema = z.object({ name: z.string().trim().min(2).max(80) });
export const deleteAccountSchema = z.object({ password: z.string().min(1).max(128) });
export const preferenceSchema = z.object({
  quoteCurrency: z.string().trim().toUpperCase().regex(/^[A-Z]{3,8}$/).optional(),
  defaultTimeframe: z.enum(['1H', '4H', '1D', '1W', '1M', '1Y']).optional(),
  theme: z.enum(['system', 'dark', 'light']).optional(),
  marketSettings: z.record(z.string(), z.unknown()).optional(),
});
export const notificationPreferenceSchema = z.object({
  signalEnabled: z.boolean().optional(),
  priceAlertEnabled: z.boolean().optional(),
  marketMovementEnabled: z.boolean().optional(),
  aiAnalysisEnabled: z.boolean().optional(),
  systemEnabled: z.boolean().optional(),
  pushEnabled: z.boolean().optional(),
});
export const watchlistCreateSchema = z.object({ assetId: assetIdSchema });
export const createAlertSchema = z.object({
  assetId: assetIdSchema,
  condition: z.enum(['ABOVE', 'BELOW']),
  targetPrice: z.coerce.number().finite().positive().max(1e15),
  active: z.boolean().optional(),
});
export const updateAlertSchema = z.object({
  condition: z.enum(['ABOVE', 'BELOW']).optional(),
  targetPrice: z.coerce.number().finite().positive().max(1e15).optional(),
  active: z.boolean().optional(),
});
export const deviceSchema = z.object({
  token: z.string().trim().min(20).max(4096),
  platform: z.enum(['android', 'ios']),
});
