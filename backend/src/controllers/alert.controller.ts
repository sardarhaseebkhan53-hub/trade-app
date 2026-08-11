import type { FastifyRequest } from 'fastify';

import { requireAuthUserId } from '../lib/api.js';
import { parse } from '../middleware/validate.js';
import { AlertService } from '../services/alert.service.js';
import { createAlertSchema, updateAlertSchema } from '../validation/schemas.js';

export class AlertController {
  constructor(private readonly service: AlertService) {}

  list(request: FastifyRequest) {
    return this.service.list(requireAuthUserId(request.auth?.userId));
  }

  create(request: FastifyRequest) {
    const input = parse(createAlertSchema, request.body);
    return this.service.create(requireAuthUserId(request.auth?.userId), input);
  }

  update(request: FastifyRequest) {
    const input = parse(updateAlertSchema, request.body);
    return this.service.update(requireAuthUserId(request.auth?.userId), (request.params as { id: string }).id, input);
  }

  async remove(request: FastifyRequest) {
    await this.service.remove(requireAuthUserId(request.auth?.userId), (request.params as { id: string }).id);
  }
}
