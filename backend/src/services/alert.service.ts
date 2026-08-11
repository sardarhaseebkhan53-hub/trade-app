import { AppError } from '../lib/api.js';
import { AlertRepository, type AlertConditionValue, type AlertStatusValue } from '../repositories/alert.repository.js';

export class AlertService {
  constructor(private readonly repository: AlertRepository) {}

  list(userId: string) {
    return this.repository.list(userId);
  }

  create(userId: string, input: { assetId: string; condition: AlertConditionValue; targetPrice: number; active?: boolean }) {
    return this.repository.create({
      userId,
      assetId: input.assetId,
      condition: input.condition,
      targetPrice: input.targetPrice.toString(),
      status: input.active === false ? 'PAUSED' : 'ACTIVE',
    });
  }

  async update(userId: string, id: string, input: { condition?: AlertConditionValue; targetPrice?: number; active?: boolean }) {
    const data: { condition?: AlertConditionValue; targetPrice?: string; status?: AlertStatusValue } = {};
    if (input.condition) data.condition = input.condition;
    if (input.targetPrice) data.targetPrice = input.targetPrice.toString();
    if (input.active !== undefined) data.status = input.active ? 'ACTIVE' : 'PAUSED';
    const result = await this.repository.update(userId, id, data);
    if (result.count === 0) throw new AppError('ALERT_NOT_FOUND', 'This alert was not found.', 404);
  }

  async remove(userId: string, id: string): Promise<void> {
    const result = await this.repository.remove(userId, id);
    if (result.count === 0) throw new AppError('ALERT_NOT_FOUND', 'This alert was not found.', 404);
  }
}
