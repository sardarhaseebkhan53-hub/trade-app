import type { PrismaClient } from '@prisma/client';

type PreferenceUpdate = {
  quoteCurrency?: string;
  defaultTimeframe?: string;
  theme?: string;
  marketSettings?: Record<string, unknown>;
};
type NotificationPreferenceUpdate = {
  signalEnabled?: boolean;
  priceAlertEnabled?: boolean;
  marketMovementEnabled?: boolean;
  aiAnalysisEnabled?: boolean;
  systemEnabled?: boolean;
  pushEnabled?: boolean;
};

export class PreferenceRepository {
  constructor(private readonly db: PrismaClient) {}

  getPreferences(userId: string) {
    return this.db.userPreference.upsert({ where: { userId }, create: { userId }, update: {} });
  }

  updatePreferences(userId: string, data: PreferenceUpdate) {
    return this.db.userPreference.upsert({ where: { userId }, create: { userId, ...data }, update: data });
  }

  getNotificationPreferences(userId: string) {
    return this.db.notificationPreference.upsert({ where: { userId }, create: { userId }, update: {} });
  }

  updateNotificationPreferences(userId: string, data: NotificationPreferenceUpdate) {
    return this.db.notificationPreference.upsert({ where: { userId }, create: { userId, ...data }, update: data });
  }
}
