import type { PrismaClient } from '@prisma/client';

export class WatchlistRepository {
  constructor(private readonly db: PrismaClient) {}

  async list(userId: string) {
    const watchlist = await this.db.watchlist.findUnique({
      where: { userId },
      include: { items: { orderBy: { createdAt: 'asc' } } },
    });
    return watchlist?.items ?? [];
  }

  async add(userId: string, assetId: string) {
    const watchlist = await this.db.watchlist.upsert({
      where: { userId },
      create: { userId },
      update: {},
      select: { id: true },
    });
    return this.db.watchlistItem.create({ data: { watchlistId: watchlist.id, assetId } });
  }

  remove(userId: string, assetId: string) {
    return this.db.watchlistItem.deleteMany({
      where: { assetId, watchlist: { userId } },
    });
  }
}
