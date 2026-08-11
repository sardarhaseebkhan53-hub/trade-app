import type { FastifyRequest } from 'fastify';

import { requireAuthUserId } from '../lib/api.js';
import { parse } from '../middleware/validate.js';
import { WatchlistService } from '../services/watchlist.service.js';
import { assetIdSchema } from '../validation/common.js';
import { watchlistCreateSchema } from '../validation/schemas.js';

export class WatchlistController {
  constructor(private readonly service: WatchlistService) {}

  list(request: FastifyRequest) {
    return this.service.list(requireAuthUserId(request.auth?.userId));
  }

  add(request: FastifyRequest) {
    const body = parse(watchlistCreateSchema, request.body);
    return this.service.add(requireAuthUserId(request.auth?.userId), body.assetId);
  }

  async remove(request: FastifyRequest) {
    const asset = parse(assetIdSchema, (request.params as { asset: string }).asset);
    await this.service.remove(requireAuthUserId(request.auth?.userId), asset);
  }
}
