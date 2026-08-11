import type { PrismaClient } from '@prisma/client';

export class UserRepository {
  constructor(private readonly db: PrismaClient) {}

  findByEmail(email: string) {
    return this.db.user.findUnique({ where: { email } });
  }

  findPublicById(id: string) {
    return this.db.user.findUnique({
      where: { id },
      select: { id: true, name: true, email: true, status: true, createdAt: true, updatedAt: true, lastLoginAt: true },
    });
  }

  create(input: { name: string; email: string; passwordHash: string }) {
    return this.db.user.create({
      data: {
        ...input,
        watchlist: { create: {} },
        preferences: { create: {} },
        notificationPreferences: { create: {} },
      },
    });
  }

  updateProfile(userId: string, name: string) {
    return this.db.user.update({
      where: { id: userId },
      data: { name },
      select: { id: true, name: true, email: true, status: true, createdAt: true, updatedAt: true, lastLoginAt: true },
    });
  }

  updatePassword(userId: string, passwordHash: string) {
    return this.db.user.update({ where: { id: userId }, data: { passwordHash } });
  }

  updateLastLogin(userId: string) {
    return this.db.user.update({ where: { id: userId }, data: { lastLoginAt: new Date() } });
  }

  async anonymizeAndDelete(userId: string): Promise<void> {
    await this.db.$transaction([
      this.db.userSession.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } }),
      this.db.user.update({
        where: { id: userId },
        data: {
          status: 'DELETED',
          email: `deleted+${userId}@invalid.aurum`,
          name: 'Deleted user',
          passwordHash: 'revoked',
        },
      }),
    ]);
  }
}
