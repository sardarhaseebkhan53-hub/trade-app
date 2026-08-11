enum MarketDataMode { remote, mock }
enum BackendMode { remote, mock }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableTelemetry,
    required this.backendMode,
    required this.marketDataMode,
    required this.marketProvider,
    required this.marketApiBaseUrl,
    required this.marketApiKey,
    required this.enableNetworkLogging,
  });

  factory AppConfig.fromEnvironment() {
    const environment = String.fromEnvironment('AURUM_ENV', defaultValue: 'development');
    const marketMode = String.fromEnvironment(
      'AURUM_MARKET_DATA_MODE',
      defaultValue: 'remote',
    );
    const backendMode = String.fromEnvironment(
      'AURUM_BACKEND_MODE',
      defaultValue: 'mock',
    );
    const apiBaseUrl = String.fromEnvironment(
      'AURUM_API_BASE_URL',
      defaultValue: 'https://api.example.invalid',
    );
    const marketApiKey = String.fromEnvironment('AURUM_MARKET_API_KEY');
    if (environment == 'production') {
      if (backendMode != 'remote' || marketMode != 'remote') {
        throw ArgumentError('Production AURUM builds require remote backend and market-data modes.');
      }
      if (marketApiKey.isNotEmpty) {
        throw ArgumentError('Production AURUM builds must not contain a market-provider API key.');
      }
      final backendUri = Uri.parse(apiBaseUrl);
      if (backendUri.scheme != 'https' || backendUri.host.isEmpty) {
        throw ArgumentError('Production AURUM builds require an HTTPS backend URL.');
      }
    }
    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableTelemetry: bool.fromEnvironment(
        'AURUM_ENABLE_TELEMETRY',
        defaultValue: false,
      ),
      backendMode: backendMode == 'remote' ? BackendMode.remote : BackendMode.mock,
      marketDataMode: marketMode == 'mock' ? MarketDataMode.mock : MarketDataMode.remote,
      marketProvider: String.fromEnvironment(
        'AURUM_MARKET_PROVIDER',
        defaultValue: 'coingecko',
      ),
      marketApiBaseUrl: String.fromEnvironment(
        'AURUM_MARKET_API_BASE_URL',
        defaultValue: 'https://api.coingecko.com/api/v3',
      ),
      marketApiKey: marketApiKey,
      enableNetworkLogging: bool.fromEnvironment(
        'AURUM_ENABLE_NETWORK_LOGGING',
        defaultValue: false,
      ),
    );
  }

  final String environment;
  final String apiBaseUrl;
  final bool enableTelemetry;
  final BackendMode backendMode;
  final MarketDataMode marketDataMode;
  final String marketProvider;
  final String marketApiBaseUrl;

  /// Development configuration only. Production apps must use an AURUM proxy.
  final String marketApiKey;
  final bool enableNetworkLogging;

  bool get hasMarketApiKey => marketApiKey.trim().isNotEmpty;
}
