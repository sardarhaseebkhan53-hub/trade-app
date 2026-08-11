import type { PrismaClient } from '@prisma/client';

export class PasswordResetRepository {
  constructor(private readonly db: PrismaClient) {}

  create(userId: string, tokenHash: string, expiresAt: Date) {
    return this.db.passwordResetToken.create({ data: { userId, tokenHash, expiresAt } });
  }

  findUsable(tokenHash: string) {
    return this.db.passwordResetToken.findFirst({ where: { tokenHash, usedAt: null, expiresAt: { gt: new Date() } } });
  }

  async consume(id: string): Promise<void> {
    await this.db.passwordResetToken.update({ where: { id }, data: { usedAt: new Date() } });
  }
}
