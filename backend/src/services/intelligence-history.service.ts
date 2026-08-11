import { IntelligenceRepository } from '../repositories/intelligence.repository.js';

type JsonValue = Record<string, unknown> | string | number | boolean | null;

export class IntelligenceHistoryService {
  constructor(private readonly repository: IntelligenceRepository) {}

  saveAiAnalysis(input: {
    userId: string;
    assetId: string;
    timeframe: string;
    structuredAnalysis: JsonValue;
    analysisVersion: string;
    marketDataTimestamp: Date;
  }) {
    return this.repository.createAiAnalysis(input);
  }

  listAiHistory(userId: string, cursor: Date | undefined, take: number) {
    return this.repository.listAiAnalyses(userId, cursor, take);
  }

  listSignalHistory(userId: string, cursor: Date | undefined, take: number) {
    return this.repository.listSignalHistory(userId, cursor, take);
  }
}
