class AnalysisRequest {
  const AnalysisRequest({required this.assetId, required this.timeframe});
  final String assetId;
  final String timeframe;

  @override
  bool operator ==(Object other) =>
      other is AnalysisRequest && other.assetId == assetId && other.timeframe == timeframe;

  @override
  int get hashCode => Object.hash(assetId, timeframe);
}
