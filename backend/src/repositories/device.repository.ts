import type { PrismaClient } from '@prisma/client';

export class DeviceRepository {
  constructor(private readonly db: PrismaClient) {}

  upsert(userId: string, tokenHash: string, platform: string) {
    return this.db.deviceRegistration.upsert({
      where: { tokenHash },
      create: { userId, tokenHash, platform },
      update: { userId, platform },
    });
  }

  remove(userId: string, id: string) {
    return this.db.deviceRegistration.deleteMany({ where: { id, userId } });
  }
}
