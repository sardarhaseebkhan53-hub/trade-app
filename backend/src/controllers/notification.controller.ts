import type { FastifyReply, FastifyRequest } from 'fastify';

import { page, requireAuthUserId } from '../lib/api.js';
import { parse } from '../middleware/validate.js';
import { NotificationService } from '../services/notification.service.js';
import { cursorSchema, pageSizeSchema } from '../validation/common.js';

export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  async list(request: FastifyRequest, reply: FastifyReply) {
    const query = request.query as { cursor?: string; limit?: string };
    const cursor = parse(cursorSchema, query.cursor);
    const limit = parse(pageSizeSchema, query.limit) ?? 20;
    const result = await this.service.list(requireAuthUserId(request.auth?.userId), cursor ? new Date(cursor) : undefined, limit);
    return page(reply, result.items, result.nextCursor);
  }

  markRead(request: FastifyRequest) {
    return this.service.markRead(requireAuthUserId(request.auth?.userId), (request.params as { id: string }).id);
  }

  markAllRead(request: FastifyRequest) {
    return this.service.markAllRead(requireAuthUserId(request.auth?.userId));
  }
}
