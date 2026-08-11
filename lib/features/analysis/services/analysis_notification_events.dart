import '../domain/analysis_models.dart';

/// Delivery is intentionally deferred to Phase 6. These are typed, opt-in-ready events.
enum AnalysisNotificationKind {
  signalCreated,
  signalInvalidated,
  significantWatchlistMove,
  analysisUpdated,
}

class AnalysisNotificationEvent {
  const AnalysisNotificationEvent({
    required this.id,
    required this.kind,
    required this.assetId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final AnalysisNotificationKind kind;
  final String assetId;
  final String title;
  final String body;
  final DateTime createdAt;
}

abstract final class AnalysisNotificationEventFactory {
  static AnalysisNotificationEvent fromSignal(SignalRecord signal) {
    final invalidated = signal.status == SignalLifecycle.invalidated;
    return AnalysisNotificationEvent(
      id: '${signal.id}:${signal.status.name}',
      kind: invalidated
          ? AnalysisNotificationKind.signalInvalidated
          : AnalysisNotificationKind.signalCreated,
      assetId: signal.assetId,
      title: invalidated ? '${signal.pair} analysis invalidated' : '${signal.pair} analysis updated',
      body: invalidated
          ? 'A prior ${signal.timeframe} analytical context is no longer current.'
          : '${signal.timeframe} ${biasLabel(signal.bias)} • strength ${signal.analyticalStrength}/100.',
      createdAt: signal.createdAt,
    );
  }
}
