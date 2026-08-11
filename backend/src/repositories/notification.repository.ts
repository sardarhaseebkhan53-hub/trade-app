import type { PrismaClient } from '@prisma/client';

export type NotificationTypeValue = 'SIGNAL_CREATED' | 'SIGNAL_INVALIDATED' | 'PRICE_ALERT' | 'MARKET_MOVEMENT' | 'AI_ANALYSIS_UPDATED' | 'SYSTEM';
type JsonValue = Record<string, unknown> | string | number | boolean | null;

export class NotificationRepository {
  constructor(private readonly db: PrismaClient) {}

  create(input: { userId: string; type: NotificationTypeValue; title: string; message: string; metadata?: JsonValue }) {
    return this.db.notification.create({ data: input });
  }

  async list(userId: string, cursor: Date | undefined, take: number) {
    const rows = await this.db.notification.findMany({
      where: { userId, ...(cursor ? { createdAt: { lt: cursor } } : {}) },
      orderBy: { createdAt: 'desc' },
      take: take + 1,
    });
    const next = rows.length > take ? rows.pop() : undefined;
    return { items: rows, nextCursor: next?.createdAt.toISOString() ?? null };
  }

  markRead(userId: string, id: string) {
    return this.db.notification.updateMany({ where: { id, userId, readAt: null }, data: { readAt: new Date() } });
  }

  markAllRead(userId: string) {
    return this.db.notification.updateMany({ where: { userId, readAt: null }, data: { readAt: new Date() } });
  }
}
