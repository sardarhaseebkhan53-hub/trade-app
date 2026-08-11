import type { PrismaClient } from '@prisma/client';

type SignalStatusValue = 'ACTIVE' | 'UPDATED' | 'INVALIDATED' | 'EXPIRED';
type JsonValue = Record<string, unknown> | string | number | boolean | null;

export class IntelligenceRepository {
  constructor(private readonly db: PrismaClient) {}

  createSignal(input: {
    assetId: string;
    timeframe: string;
    bias: string;
    analyticalStrength: number;
    supportingFactors: JsonValue;
    conflictingFactors: JsonValue;
    riskFactors: JsonValue;
    invalidationConditions: JsonValue;
    status: SignalStatusValue;
    analysisVersion: string;
    marketDataTimestamp: Date;
    expiresAt: Date;
  }) {
    return this.db.signal.create({ data: input });
  }

  listSignalHistory(userId: string, cursor: Date | undefined, take: number) {
    return this.db.signalHistory.findMany({
      where: { userId, ...(cursor ? { createdAt: { lt: cursor } } : {}) },
      include: { signal: true },
      orderBy: { createdAt: 'desc' },
      take,
    });
  }

  createAiAnalysis(input: {
    userId: string;
    assetId: string;
    timeframe: string;
    structuredAnalysis: JsonValue;
    analysisVersion: string;
    marketDataTimestamp: Date;
  }) {
    return this.db.aIAnalysis.create({ data: input });
  }

  listAiAnalyses(userId: string, cursor: Date | undefined, take: number) {
    return this.db.aIAnalysis.findMany({
      where: { userId, ...(cursor ? { createdAt: { lt: cursor } } : {}) },
      orderBy: { createdAt: 'desc' },
      take,
    });
  }
}
