import { AppError } from '../lib/api.js';
import { PreferenceRepository } from '../repositories/preference.repository.js';
import { UserRepository } from '../repositories/user.repository.js';

export class ProfileService {
  constructor(
    private readonly users: UserRepository,
    private readonly preferences: PreferenceRepository,
  ) {}

  async me(userId: string) {
    const user = await this.users.findPublicById(userId);
    if (!user) throw new AppError('USER_NOT_FOUND', 'Account not found.', 404);
    return user;
  }

  updateProfile(userId: string, name: string) {
    return this.users.updateProfile(userId, name);
  }

  getPreferences(userId: string) {
    return this.preferences.getPreferences(userId);
  }

  updatePreferences(userId: string, data: Parameters<PreferenceRepository['updatePreferences']>[1]) {
    return this.preferences.updatePreferences(userId, data);
  }

  getNotificationPreferences(userId: string) {
    return this.preferences.getNotificationPreferences(userId);
  }

  updateNotificationPreferences(userId: string, data: Parameters<PreferenceRepository['updateNotificationPreferences']>[1]) {
    return this.preferences.updateNotificationPreferences(userId, data);
  }
}
