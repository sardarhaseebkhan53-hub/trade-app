import { AppError } from '../lib/api.js';
import { WatchlistRepository } from '../repositories/watchlist.repository.js';

export class WatchlistService {
  constructor(private readonly repository: WatchlistRepository) {}

  list(userId: string) {
    return this.repository.list(userId);
  }

  async add(userId: string, assetId: string) {
    try {
      return await this.repository.add(userId, assetId);
    } catch (error: unknown) {
      if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'P2002') {
        throw new AppError('WATCHLIST_DUPLICATE', 'This asset is already in your watchlist.', 409);
      }
      throw error;
    }
  }

  async remove(userId: string, assetId: string): Promise<void> {
    const result = await this.repository.remove(userId, assetId);
    if (result.count === 0) throw new AppError('WATCHLIST_NOT_FOUND', 'This watchlist item was not found.', 404);
  }
}
