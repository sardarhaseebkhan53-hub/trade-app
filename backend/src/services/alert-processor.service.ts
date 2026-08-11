import { AlertRepository } from '../repositories/alert.repository.js';
import { PreferenceRepository } from '../repositories/preference.repository.js';
import { NotificationService } from './notification.service.js';

export interface MarketQuoteProvider {
  getUsdPrice(assetId: string): Promise<number | null>;
}

/// Invoked by a scheduled backend worker, never by a Flutter widget.
export class AlertProcessorService {
  constructor(
    private readonly alerts: AlertRepository,
    private readonly preferences: PreferenceRepository,
    private readonly notifications: NotificationService,
    private readonly quotes: MarketQuoteProvider,
  ) {}

  async processAsset(assetId: string): Promise<number> {
    const price = await this.quotes.getUsdPrice(assetId);
    if (price === null || !Number.isFinite(price)) return 0;
    const alerts = await this.alerts.activeForAsset(assetId);
    let triggered = 0;
    for (const alert of alerts) {
      const target = Number(alert.targetPrice);
      const matches = alert.condition === 'ABOVE' ? price >= target : price <= target;
      if (!matches) continue;
      await this.alerts.markTriggered(alert.id);
      const preferences = await this.preferences.getNotificationPreferences(alert.userId);
      if (preferences.priceAlertEnabled) {
        await this.notifications.create({
          userId: alert.userId,
          type: 'PRICE_ALERT',
          title: `${assetId.toUpperCase()} price alert triggered`,
          message: `${assetId.toUpperCase()} is ${alert.condition.toLowerCase()} your configured price level.`,
          metadata: { assetId, targetPrice: target, observedPrice: price, condition: alert.condition },
        });
      }
      triggered++;
    }
    return triggered;
  }
}
