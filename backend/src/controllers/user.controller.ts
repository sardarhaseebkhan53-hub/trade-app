import type { FastifyRequest } from 'fastify';

import { requireAuthUserId } from '../lib/api.js';
import { parse } from '../middleware/validate.js';
import { ProfileService } from '../services/profile.service.js';
import { notificationPreferenceSchema, preferenceSchema, profileSchema } from '../validation/schemas.js';

export class UserController {
  constructor(private readonly profile: ProfileService) {}

  me(request: FastifyRequest) {
    return this.profile.me(requireAuthUserId(request.auth?.userId));
  }

  updateMe(request: FastifyRequest) {
    const input = parse(profileSchema, request.body);
    return this.profile.updateProfile(requireAuthUserId(request.auth?.userId), input.name);
  }

  preferences(request: FastifyRequest) {
    return this.profile.getPreferences(requireAuthUserId(request.auth?.userId));
  }

  updatePreferences(request: FastifyRequest) {
    const input = parse(preferenceSchema, request.body);
    return this.profile.updatePreferences(requireAuthUserId(request.auth?.userId), input);
  }

  notificationPreferences(request: FastifyRequest) {
    return this.profile.getNotificationPreferences(requireAuthUserId(request.auth?.userId));
  }

  updateNotificationPreferences(request: FastifyRequest) {
    const input = parse(notificationPreferenceSchema, request.body);
    return this.profile.updateNotificationPreferences(requireAuthUserId(request.auth?.userId), input);
  }
}
