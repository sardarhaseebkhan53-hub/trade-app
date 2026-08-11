import type { PrismaClient } from '@prisma/client';

export type AlertConditionValue = 'ABOVE' | 'BELOW';
export type AlertStatusValue = 'ACTIVE' | 'TRIGGERED' | 'PAUSED' | 'CANCELLED';

export class AlertRepository {
  constructor(private readonly db: PrismaClient) {}

  list(userId: string) {
    return this.db.priceAlert.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
  }

  create(input: { userId: string; assetId: string; condition: AlertConditionValue; targetPrice: string; status: AlertStatusValue }) {
    return this.db.priceAlert.create({ data: input });
  }

  update(userId: string, id: string, data: { condition?: AlertConditionValue; targetPrice?: string; status?: AlertStatusValue }) {
    return this.db.priceAlert.updateMany({ where: { id, userId }, data });
  }

  remove(userId: string, id: string) {
    return this.db.priceAlert.deleteMany({ where: { id, userId } });
  }

  activeForAsset(assetId: string) {
    return this.db.priceAlert.findMany({ where: { assetId, status: 'ACTIVE' } });
  }

  markTriggered(id: string) {
    return this.db.priceAlert.update({ where: { id }, data: { status: 'TRIGGERED', triggeredAt: new Date() } });
  }
}
