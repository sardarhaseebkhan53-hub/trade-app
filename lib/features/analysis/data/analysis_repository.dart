import '../../../shared/services/repositories.dart';
import '../domain/analysis_models.dart';
import '../domain/analysis_request.dart';
import '../services/market_analysis_engine.dart';
import '../services/signal_engine.dart';
import '../services/technical_analysis_service.dart';

class AnalysisRepository {
  AnalysisRepository({
    required MarketRepository marketRepository,
    TechnicalAnalysisService? technicalService,
    MarketAnalysisEngine? analysisEngine,
  })  : _marketRepository = marketRepository,
        _technicalService = technicalService ?? const TechnicalAnalysisService(),
        _analysisEngine = analysisEngine ?? const MarketAnalysisEngine();

  final MarketRepository _marketRepository;
  final TechnicalAnalysisService _technicalService;
  final MarketAnalysisEngine _analysisEngine;

  Future<MarketAnalysis> analyze(AnalysisRequest request) async {
    final asset = await _marketRepository.getAsset(request.assetId);
    final chart = await _marketRepository.getChart(request.assetId, request.timeframe);
    final technical = _technicalService.evaluate(chart.data);
    return _analysisEngine.analyze(
      asset: asset.data,
      timeframe: request.timeframe,
      dataAsOf: chart.asOf,
      technical: technical,
    );
  }

  Future<Map<String, MarketAnalysis>> analyzeMultipleTimeframes(String assetId) async {
    const timeframes = <String>['1H', '4H', '1D', '1W'];
    final results = <String, MarketAnalysis>{};
    for (final timeframe in timeframes) {
      results[timeframe] = await analyze(AnalysisRequest(assetId: assetId, timeframe: timeframe));
    }
    return Map<String, MarketAnalysis>.unmodifiable(results);
  }
}

class SignalFeedRepository {
  SignalFeedRepository({
    required MarketRepository marketRepository,
    required AnalysisRepository analysisRepository,
    required SignalEngine signalEngine,
    required SignalHistoryStore history,
  })  : _marketRepository = marketRepository,
        _analysisRepository = analysisRepository,
        _signalEngine = signalEngine,
        _history = history;

  final MarketRepository _marketRepository;
  final AnalysisRepository _analysisRepository;
  final SignalEngine _signalEngine;
  final SignalHistoryStore _history;

  Future<List<SignalRecord>> generateFeatured({String timeframe = '1D'}) async {
    final featured = await _marketRepository.getFeaturedAssets();
    for (final asset in featured.data) {
      final analysis = await _analysisRepository.analyze(
        AnalysisRequest(assetId: asset.id, timeframe: timeframe),
      );
      _history.record(_signalEngine.evaluate(analysis));
    }
    return _history.all;
  }

  Future<List<SignalRecord>> generateForAsset(String assetId, {String timeframe = '1D'}) async {
    final analysis = await _analysisRepository.analyze(
      AnalysisRequest(assetId: assetId, timeframe: timeframe),
    );
    _history.record(_signalEngine.evaluate(analysis));
    return _history.recordsFor(assetId);
  }
}
