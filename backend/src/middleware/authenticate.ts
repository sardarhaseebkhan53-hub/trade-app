import type { FastifyReply, FastifyRequest } from 'fastify';

import { AppError } from '../lib/api.js';
import { hashToken } from '../lib/tokens.js';
import { SessionRepository } from '../repositories/session.repository.js';

export function authenticate(sessionRepository: SessionRepository) {
  return async function requireAuthentication(request: FastifyRequest, _reply: FastifyReply): Promise<void> {
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) throw new AppError('AUTH_UNAUTHORIZED', 'Authentication is required.', 401);
    const session = await sessionRepository.findActiveByAccessToken(hashToken(header.slice(7)));
    if (!session) throw new AppError('AUTH_SESSION_EXPIRED', 'Your session has ended. Please sign in again.', 401);
    request.auth = { userId: session.userId, sessionId: session.id };
    await sessionRepository.touch(session.id);
  };
}
