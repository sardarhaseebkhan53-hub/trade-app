import type { FastifyRequest } from 'fastify';

import { requireAuthUserId } from '../lib/api.js';
import { hashToken } from '../lib/tokens.js';
import { DeviceRepository } from '../repositories/device.repository.js';
import { parse } from '../middleware/validate.js';
import { deviceSchema } from '../validation/schemas.js';

export class DeviceController {
  constructor(private readonly devices: DeviceRepository) {}

  register(request: FastifyRequest) {
    const input = parse(deviceSchema, request.body);
    return this.devices.upsert(requireAuthUserId(request.auth?.userId), hashToken(input.token), input.platform);
  }

  remove(request: FastifyRequest) {
    return this.devices.remove(requireAuthUserId(request.auth?.userId), (request.params as { id: string }).id);
  }
}
