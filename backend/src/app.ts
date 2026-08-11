import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import type { PrismaClient } from '@prisma/client';
import Fastify from 'fastify';

import { loadEnv, type Env } from './config/env.js';
import { AlertController } from './controllers/alert.controller.js';
import { AuthController } from './controllers/auth.controller.js';
import { DeviceController } from './controllers/device.controller.js';
import { IntelligenceController } from './controllers/intelligence.controller.js';
import { NotificationController } from './controllers/notification.controller.js';
import { UserController } from './controllers/user.controller.js';
import { WatchlistController } from './controllers/watchlist.controller.js';
import { AppError, ok } from './lib/api.js';
import { prisma } from './lib/prisma.js';
import { authenticate } from './middleware/authenticate.js';
import { AlertRepository } from './repositories/alert.repository.js';
import { DeviceRepository } from './repositories/device.repository.js';
import { IntelligenceRepository } from './repositories/intelligence.repository.js';
import { NotificationRepository } from './repositories/notification.repository.js';
import { PasswordResetRepository } from './repositories/password-reset.repository.js';
import { PreferenceRepository } from './repositories/preference.repository.js';
import { SessionRepository } from './repositories/session.repository.js';
import { UserRepository } from './repositories/user.repository.js';
import { WatchlistRepository } from './repositories/watchlist.repository.js';
import { AlertService } from './services/alert.service.js';
import { AuthService } from './services/auth.service.js';
import { IntelligenceHistoryService } from './services/intelligence-history.service.js';
import { NotificationService } from './services/notification.service.js';
import { ProfileService } from './services/profile.service.js';
import { WatchlistService } from './services/watchlist.service.js';

export async function buildApp(options: { env?: Env; db?: PrismaClient } = {}) {
  const env = options.env ?? loadEnv();
  const db = options.db ?? prisma;
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
      redact: ['req.headers.authorization', 'req.body.password', 'req.body.refreshToken', 'req.body.token'],
    },
    bodyLimit: 64 * 1024,
  });

  const allowedOrigins = env.CORS_ORIGINS.split(',').map((value) => value.trim()).filter(Boolean);
  await app.register(helmet, { contentSecurityPolicy: false });
  await app.register(cors, { origin: allowedOrigins.length === 0 ? false : allowedOrigins });
  await app.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
    errorResponseBuilder: () => ({ success: false, error: { code: 'RATE_LIMITED', message: 'Too many requests. Please try again shortly.' } }),
  });

  const users = new UserRepository(db);
  const sessions = new SessionRepository(db);
  const preferences = new PreferenceRepository(db);
  const watchlists = new WatchlistRepository(db);
  const alerts = new AlertRepository(db);
  const notifications = new NotificationRepository(db);
  const devices = new DeviceRepository(db);
  const intelligence = new IntelligenceRepository(db);
  const auth = new AuthService(users, sessions, new PasswordResetRepository(db), env);
  const profile = new ProfileService(users, preferences);
  const authController = new AuthController(auth, profile);
  const userController = new UserController(profile);
  const watchlistController = new WatchlistController(new WatchlistService(watchlists));
  const alertController = new AlertController(new AlertService(alerts));
  const notificationController = new NotificationController(new NotificationService(notifications));
  const deviceController = new DeviceController(devices);
  const intelligenceController = new IntelligenceController(new IntelligenceHistoryService(intelligence));
  const requireAuth = authenticate(sessions);

  app.get('/health', async (_request, reply) => ok(reply, { status: 'ok' }));

  app.post('/auth/register', { config: { rateLimit: { max: 8, timeWindow: '1 minute' } } }, async (request, reply) => ok(reply, await authController.register(request), 201));
  app.post('/auth/login', { config: { rateLimit: { max: 10, timeWindow: '1 minute' } } }, async (request, reply) => ok(reply, await authController.login(request)));
  app.post('/auth/refresh', { config: { rateLimit: { max: 20, timeWindow: '1 minute' } } }, async (request, reply) => ok(reply, await authController.refresh(request)));
  app.post('/auth/forgot-password', { config: { rateLimit: { max: 5, timeWindow: '15 minutes' } } }, async (request, reply) => ok(reply, await authController.forgotPassword(request), 202));
  app.post('/auth/reset-password', { config: { rateLimit: { max: 5, timeWindow: '15 minutes' } } }, async (request, reply) => { await authController.resetPassword(request); return ok(reply, { reset: true }); });
  app.get('/auth/me', { preHandler: requireAuth }, async (request, reply) => ok(reply, await authController.me(request)));
  app.post('/auth/logout', { preHandler: requireAuth }, async (request, reply) => { await authController.logout(request); return ok(reply, { loggedOut: true }); });

  app.get('/users/me', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.me(request)));
  app.patch('/users/me', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.updateMe(request)));
  app.delete('/users/me', { preHandler: requireAuth }, async (request, reply) => { await authController.deleteAccount(request); return ok(reply, { deleted: true }); });
  app.get('/users/preferences', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.preferences(request)));
  app.patch('/users/preferences', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.updatePreferences(request)));
  app.get('/users/notification-preferences', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.notificationPreferences(request)));
  app.patch('/users/notification-preferences', { preHandler: requireAuth }, async (request, reply) => ok(reply, await userController.updateNotificationPreferences(request)));

  app.get('/watchlist', { preHandler: requireAuth }, async (request, reply) => ok(reply, await watchlistController.list(request)));
  app.post('/watchlist', { preHandler: requireAuth }, async (request, reply) => ok(reply, await watchlistController.add(request), 201));
  app.delete('/watchlist/:asset', { preHandler: requireAuth }, async (request, reply) => { await watchlistController.remove(request); return ok(reply, { removed: true }); });

  app.get('/alerts', { preHandler: requireAuth }, async (request, reply) => ok(reply, await alertController.list(request)));
  app.post('/alerts', { preHandler: requireAuth }, async (request, reply) => ok(reply, await alertController.create(request), 201));
  app.patch('/alerts/:id', { preHandler: requireAuth }, async (request, reply) => { await alertController.update(request); return ok(reply, { updated: true }); });
  app.delete('/alerts/:id', { preHandler: requireAuth }, async (request, reply) => { await alertController.remove(request); return ok(reply, { deleted: true }); });

  app.get('/notifications', { preHandler: requireAuth }, (request, reply) => notificationController.list(request, reply));
  app.patch('/notifications/:id/read', { preHandler: requireAuth }, async (request, reply) => ok(reply, await notificationController.markRead(request)));
  app.patch('/notifications/read-all', { preHandler: requireAuth }, async (request, reply) => ok(reply, await notificationController.markAllRead(request)));

  app.post('/devices', { preHandler: requireAuth }, async (request, reply) => ok(reply, await deviceController.register(request), 201));
  app.delete('/devices/:id', { preHandler: requireAuth }, async (request, reply) => ok(reply, await deviceController.remove(request)));
  app.get('/signals/history', { preHandler: requireAuth }, (request, reply) => intelligenceController.signalHistory(request, reply));
  app.get('/ai-analyses/history', { preHandler: requireAuth }, (request, reply) => intelligenceController.aiHistory(request, reply));

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.code(error.statusCode).send({ success: false, error: { code: error.code, message: error.message } });
    }
    if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'P2002') {
      return reply.code(409).send({ success: false, error: { code: 'CONFLICT', message: 'This record already exists.' } });
    }
    app.log.error({ err: error }, 'Unhandled API error');
    return reply.code(500).send({ success: false, error: { code: 'INTERNAL_ERROR', message: 'Unable to complete this request.' } });
  });

  app.addHook('onClose', async () => {
    if (options.db === undefined) await db.$disconnect();
  });
  return app;
}
