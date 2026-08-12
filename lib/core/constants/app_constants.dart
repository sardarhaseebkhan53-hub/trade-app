class AppConstants {
  static const String appName = 'AURUM';
  static const String tagline = 'MARKET INTELLIGENCE';
  static const String disclaimer =
      'AURUM provides market analysis and decision-support information only. '
      'It does not constitute financial advice. Cryptocurrency markets are volatile. '
      'Past performance is not indicative of future results.';

  static const int defaultPageSize = 50;
  static const Duration apiTimeout = Duration(seconds: 12);
  static const Duration cacheTTLShort = Duration(seconds: 60);
  static const Duration cacheTTLMedium = Duration(minutes: 5);
}
