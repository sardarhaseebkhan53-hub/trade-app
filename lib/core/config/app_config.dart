enum MarketDataMode { remote, mock }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableTelemetry,
    required this.marketDataMode,
    required this.marketProvider,
    required this.marketApiBaseUrl,
    required this.marketApiKey,
    required this.enableNetworkLogging,
  });

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment(
      'AURUM_MARKET_DATA_MODE',
      defaultValue: 'remote',
    );
    return AppConfig(
      environment: String.fromEnvironment('AURUM_ENV', defaultValue: 'development'),
      apiBaseUrl: String.fromEnvironment(
        'AURUM_API_BASE_URL',
        defaultValue: 'https://api.example.invalid',
      ),
      enableTelemetry: bool.fromEnvironment(
        'AURUM_ENABLE_TELEMETRY',
        defaultValue: false,
      ),
      marketDataMode: mode == 'mock' ? MarketDataMode.mock : MarketDataMode.remote,
      marketProvider: String.fromEnvironment(
        'AURUM_MARKET_PROVIDER',
        defaultValue: 'coingecko',
      ),
      marketApiBaseUrl: String.fromEnvironment(
        'AURUM_MARKET_API_BASE_URL',
        defaultValue: 'https://api.coingecko.com/api/v3',
      ),
      marketApiKey: String.fromEnvironment('AURUM_MARKET_API_KEY'),
      enableNetworkLogging: bool.fromEnvironment(
        'AURUM_ENABLE_NETWORK_LOGGING',
        defaultValue: false,
      ),
    );
  }

  final String environment;
  final String apiBaseUrl;
  final bool enableTelemetry;
  final MarketDataMode marketDataMode;
  final String marketProvider;
  final String marketApiBaseUrl;

  /// Development configuration only. Production apps must use an AURUM proxy.
  final String marketApiKey;
  final bool enableNetworkLogging;

  bool get hasMarketApiKey => marketApiKey.trim().isNotEmpty;
}
