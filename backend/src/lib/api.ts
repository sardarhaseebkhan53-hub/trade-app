import type { FastifyReply } from 'fastify';

export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly message: string,
    public readonly statusCode = 400,
  ) {
    super(message);
  }
}

export function ok<T>(reply: FastifyReply, data: T, statusCode = 200): FastifyReply {
  return reply.code(statusCode).send({ success: true, data });
}

export function page<T>(reply: FastifyReply, data: T[], nextCursor: string | null): FastifyReply {
  return reply.send({ success: true, data: { items: data, nextCursor } });
}

export function requireAuthUserId(value: string | undefined): string {
  if (!value) throw new AppError('AUTH_UNAUTHORIZED', 'Authentication is required.', 401);
  return value;
}
