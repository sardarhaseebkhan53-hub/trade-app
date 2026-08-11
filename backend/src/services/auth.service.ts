import type { Env } from '../config/env.js';
import { AppError } from '../lib/api.js';
import { hashPassword, verifyPassword } from '../lib/passwords.js';
import { generateOpaqueToken, hashToken } from '../lib/tokens.js';
import { PasswordResetRepository } from '../repositories/password-reset.repository.js';
import { SessionRepository } from '../repositories/session.repository.js';
import { UserRepository } from '../repositories/user.repository.js';

export type SessionEnvelope = {
  accessToken: string;
  refreshToken: string;
  accessExpiresAt: Date;
  refreshExpiresAt: Date;
};

export class AuthService {
  constructor(
    private readonly users: UserRepository,
    private readonly sessions: SessionRepository,
    private readonly resets: PasswordResetRepository,
    private readonly env: Env,
  ) {}

  async register(input: { name: string; email: string; password: string; deviceId?: string; userAgent?: string }) {
    if (await this.users.findByEmail(input.email)) {
      throw new AppError('AUTH_EMAIL_UNAVAILABLE', 'An account could not be created with those details.', 409);
    }
    const user = await this.users.create({ name: input.name, email: input.email, passwordHash: await hashPassword(input.password) });
    const session = await this.createSession(user.id, input.deviceId, input.userAgent);
    return { user: this.publicUser(user), session };
  }

  async login(input: { email: string; password: string; deviceId?: string; userAgent?: string }) {
    const user = await this.users.findByEmail(input.email);
    const valid = user && user.status === 'ACTIVE' && await verifyPassword(user.passwordHash, input.password);
    if (!valid || !user) {
      throw new AppError('AUTH_INVALID_CREDENTIALS', 'The email or password is incorrect.', 401);
    }
    await this.users.updateLastLogin(user.id);
    const session = await this.createSession(user.id, input.deviceId, input.userAgent);
    return { user: this.publicUser(user), session };
  }

  async refresh(refreshToken: string, deviceId?: string, userAgent?: string): Promise<SessionEnvelope> {
    const session = await this.sessions.findActiveByRefreshToken(hashToken(refreshToken));
    if (!session) throw new AppError('AUTH_SESSION_EXPIRED', 'Your session has ended. Please sign in again.', 401);
    await this.sessions.revoke(session.id);
    return this.createSession(session.userId, deviceId ?? session.deviceId ?? undefined, userAgent ?? session.userAgent ?? undefined);
  }

  async logout(sessionId: string): Promise<void> {
    await this.sessions.revoke(sessionId);
  }

  async requestPasswordReset(email: string): Promise<void> {
    const user = await this.users.findByEmail(email);
    if (!user || user.status !== 'ACTIVE') return;
    const rawToken = generateOpaqueToken();
    await this.resets.create(
      user.id,
      hashToken(rawToken),
      new Date(Date.now() + this.env.PASSWORD_RESET_TTL_MINUTES * 60_000),
    );
    // Email delivery is a provider adapter. Never log or return raw reset tokens in production.
  }

  async resetPassword(rawToken: string, password: string): Promise<void> {
    const token = await this.resets.findUsable(hashToken(rawToken));
    if (!token) throw new AppError('AUTH_RESET_INVALID', 'This password reset link is invalid or expired.', 400);
    await this.users.updatePassword(token.userId, await hashPassword(password));
    await this.resets.consume(token.id);
    await this.sessions.revokeForUser(token.userId);
  }

  async deleteAccount(userId: string, password: string): Promise<void> {
    const user = await this.users.findByEmail((await this.users.findPublicById(userId))?.email ?? '');
    if (!user || !await verifyPassword(user.passwordHash, password)) {
      throw new AppError('AUTH_REAUTH_REQUIRED', 'Please sign in again before deleting your account.', 401);
    }
    await this.sessions.revokeForUser(userId);
    await this.users.anonymizeAndDelete(userId);
  }

  private async createSession(userId: string, deviceId?: string, userAgent?: string): Promise<SessionEnvelope> {
    const accessToken = generateOpaqueToken();
    const refreshToken = generateOpaqueToken();
    const accessExpiresAt = new Date(Date.now() + this.env.ACCESS_TOKEN_TTL_MINUTES * 60_000);
    const refreshExpiresAt = new Date(Date.now() + this.env.REFRESH_TOKEN_TTL_DAYS * 86_400_000);
    await this.sessions.create({
      userId,
      accessTokenHash: hashToken(accessToken),
      refreshTokenHash: hashToken(refreshToken),
      accessExpiresAt,
      refreshExpiresAt,
      deviceId,
      userAgent,
    });
    return { accessToken, refreshToken, accessExpiresAt, refreshExpiresAt };
  }

  private publicUser(user: { id: string; name: string; email: string; status: string; createdAt: Date; updatedAt: Date; lastLoginAt: Date | null }) {
    return { id: user.id, name: user.name, email: user.email, status: user.status, createdAt: user.createdAt, updatedAt: user.updatedAt, lastLoginAt: user.lastLoginAt };
  }
}
