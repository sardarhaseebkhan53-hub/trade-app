import type { PrismaClient } from '@prisma/client';

export class SessionRepository {
  constructor(private readonly db: PrismaClient) {}

  create(input: {
    userId: string;
    accessTokenHash: string;
    refreshTokenHash: string;
    accessExpiresAt: Date;
    refreshExpiresAt: Date;
    deviceId?: string;
    userAgent?: string;
  }) {
    return this.db.userSession.create({ data: input });
  }

  findActiveByAccessToken(accessTokenHash: string) {
    return this.db.userSession.findFirst({
      where: { accessTokenHash, revokedAt: null, accessExpiresAt: { gt: new Date() } },
    });
  }

  findActiveByRefreshToken(refreshTokenHash: string) {
    return this.db.userSession.findFirst({
      where: { refreshTokenHash, revokedAt: null, refreshExpiresAt: { gt: new Date() } },
    });
  }

  touch(id: string) {
    return this.db.userSession.update({ where: { id }, data: { lastUsedAt: new Date() } });
  }

  revoke(id: string) {
    return this.db.userSession.updateMany({ where: { id, revokedAt: null }, data: { revokedAt: new Date() } });
  }

  revokeForUser(userId: string) {
    return this.db.userSession.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } });
  }
}
