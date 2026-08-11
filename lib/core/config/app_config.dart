class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableTelemetry,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      environment: String.fromEnvironment('AURUM_ENV', defaultValue: 'development'),
      apiBaseUrl: String.fromEnvironment(
        'AURUM_API_BASE_URL',
        defaultValue: 'https://api.example.invalid',
      ),
      enableTelemetry: bool.fromEnvironment(
        'AURUM_ENABLE_TELEMETRY',
        defaultValue: false,
      ),
    );
  }

  final String environment;
  final String apiBaseUrl;
  final bool enableTelemetry;
}
