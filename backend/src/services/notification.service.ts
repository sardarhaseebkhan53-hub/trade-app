import { NotificationRepository, type NotificationTypeValue } from '../repositories/notification.repository.js';

type JsonValue = Record<string, unknown> | string | number | boolean | null;

export class NotificationService {
  constructor(private readonly repository: NotificationRepository) {}

  create(input: { userId: string; type: NotificationTypeValue; title: string; message: string; metadata?: JsonValue }) {
    return this.repository.create(input);
  }

  list(userId: string, cursor: Date | undefined, take: number) {
    return this.repository.list(userId, cursor, take);
  }

  markRead(userId: string, id: string) {
    return this.repository.markRead(userId, id);
  }

  markAllRead(userId: string) {
    return this.repository.markAllRead(userId);
  }
}
