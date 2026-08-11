import type { FastifyRequest } from 'fastify';

import { requireAuthUserId } from '../lib/api.js';
import { ProfileService } from '../services/profile.service.js';
import { AuthService } from '../services/auth.service.js';
import { parse } from '../middleware/validate.js';
import { deleteAccountSchema, forgotPasswordSchema, loginSchema, refreshSchema, registerSchema, resetPasswordSchema } from '../validation/schemas.js';

export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly profile: ProfileService,
  ) {}

  async register(request: FastifyRequest) {
    const input = parse(registerSchema, request.body);
    return this.auth.register({ ...input, userAgent: request.headers['user-agent'] });
  }

  async login(request: FastifyRequest) {
    const input = parse(loginSchema, request.body);
    return this.auth.login({ ...input, userAgent: request.headers['user-agent'] });
  }

  async logout(request: FastifyRequest) {
    await this.auth.logout(requireAuthUserId(request.auth?.sessionId));
  }

  async refresh(request: FastifyRequest) {
    const input = parse(refreshSchema, request.body);
    return this.auth.refresh(input.refreshToken, undefined, request.headers['user-agent']);
  }

  async forgotPassword(request: FastifyRequest) {
    const input = parse(forgotPasswordSchema, request.body);
    await this.auth.requestPasswordReset(input.email);
    return { message: 'If an account matches that email, password reset instructions will be sent.' };
  }

  async resetPassword(request: FastifyRequest) {
    const input = parse(resetPasswordSchema, request.body);
    await this.auth.resetPassword(input.token, input.password);
  }

  async me(request: FastifyRequest) {
    return this.profile.me(requireAuthUserId(request.auth?.userId));
  }

  async deleteAccount(request: FastifyRequest) {
    const input = parse(deleteAccountSchema, request.body);
    await this.auth.deleteAccount(requireAuthUserId(request.auth?.userId), input.password);
  }
}
