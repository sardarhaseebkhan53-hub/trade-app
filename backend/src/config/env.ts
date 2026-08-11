import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(8080),
  HOST: z.string().default('0.0.0.0'),
  LOG_LEVEL: z.string().default('info'),
  DATABASE_URL: z.string().url(),
  ACCESS_TOKEN_TTL_MINUTES: z.coerce.number().int().min(5).max(120).default(30),
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().min(1).max(90).default(30),
  PASSWORD_RESET_TTL_MINUTES: z.coerce.number().int().min(5).max(120).default(30),
  CORS_ORIGINS: z.string().default(''),
  MARKET_PROVIDER_BASE_URL: z.string().url().optional(),
  MARKET_PROVIDER_API_KEY: z.string().optional(),
  AI_PROVIDER_BASE_URL: z.string().url().optional(),
  AI_PROVIDER_API_KEY: z.string().optional(),
  FCM_SERVICE_ACCOUNT_JSON: z.string().optional(),
});

export type Env = z.infer<typeof schema>;

export function loadEnv(input: NodeJS.ProcessEnv = process.env): Env {
  const result = schema.safeParse(input);
  if (!result.success) {
    throw new Error(`Invalid environment configuration: ${result.error.issues.map((issue) => issue.path.join('.')).join(', ')}`);
  }
  return result.data;
}
