import type { FastifyReply, FastifyRequest } from 'fastify';

import { page, requireAuthUserId } from '../lib/api.js';
import { parse } from '../middleware/validate.js';
import { IntelligenceHistoryService } from '../services/intelligence-history.service.js';
import { cursorSchema, pageSizeSchema } from '../validation/common.js';

export class IntelligenceController {
  constructor(private readonly service: IntelligenceHistoryService) {}

  async signalHistory(request: FastifyRequest, reply: FastifyReply) {
    const query = request.query as { cursor?: string; limit?: string };
    const cursor = parse(cursorSchema, query.cursor);
    const limit = parse(pageSizeSchema, query.limit) ?? 20;
    const items = await this.service.listSignalHistory(requireAuthUserId(request.auth?.userId), cursor ? new Date(cursor) : undefined, limit);
    const next = items.length === limit ? items[items.length - 1]?.createdAt.toISOString() ?? null : null;
    return page(reply, items, next);
  }

  async aiHistory(request: FastifyRequest, reply: FastifyReply) {
    const query = request.query as { cursor?: string; limit?: string };
    const cursor = parse(cursorSchema, query.cursor);
    const limit = parse(pageSizeSchema, query.limit) ?? 20;
    const items = await this.service.listAiHistory(requireAuthUserId(request.auth?.userId), cursor ? new Date(cursor) : undefined, limit);
    const next = items.length === limit ? items[items.length - 1]?.createdAt.toISOString() ?? null : null;
    return page(reply, items, next);
  }
}
