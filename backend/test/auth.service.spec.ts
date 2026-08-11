import { describe, expect, it, vi } from 'vitest';

import { hashPassword } from '../src/lib/passwords.js';
import { AuthService } from '../src/services/auth.service.js';

const env = {
  NODE_ENV: 'test' as const,
  PORT: 8080,
  HOST: '0.0.0.0',
  LOG_LEVEL: 'silent',
  DATABASE_URL: 'postgresql://test',
  ACCESS_TOKEN_TTL_MINUTES: 30,
  REFRESH_TOKEN_TTL_DAYS: 30,
  PASSWORD_RESET_TTL_MINUTES: 30,
  CORS_ORIGINS: '',
};

describe('AuthService', () => {
  it('rejects duplicate email registration', async () => {
    const users = { findByEmail: vi.fn().mockResolvedValue({ id: 'user-1' }) };
    const service = new AuthService(users as never, {} as never, {} as never, env);

    await expect(service.register({ name: 'Aurum User', email: 'user@example.com', password: 'Password1234' }))
      .rejects.toMatchObject({ code: 'AUTH_EMAIL_UNAVAILABLE' });
  });

  it('rejects an invalid password without issuing a session', async () => {
    const users = {
      findByEmail: vi.fn().mockResolvedValue({
        id: 'user-1', name: 'Aurum User', email: 'user@example.com', status: 'ACTIVE',
        passwordHash: await hashPassword('CorrectPassword123'), createdAt: new Date(), updatedAt: new Date(), lastLoginAt: null,
      }),
    };
    const service = new AuthService(users as never, {} as never, {} as never, env);

    await expect(service.login({ email: 'user@example.com', password: 'WrongPassword123' }))
      .rejects.toMatchObject({ code: 'AUTH_INVALID_CREDENTIALS' });
  });
});
