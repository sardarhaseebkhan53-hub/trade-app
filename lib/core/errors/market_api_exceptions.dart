import 'dart:async';

sealed class MarketApiException implements Exception {
  const MarketApiException(this.userMessage, {this.statusCode, this.cause});

  final String userMessage;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => '$runtimeType($statusCode): $userMessage';
}

class NetworkException extends MarketApiException {
  const NetworkException({Object? cause})
      : super('Unable to update market data. Check your connection and try again.', cause: cause);
}

class ApiTimeoutException extends MarketApiException {
  const ApiTimeoutException({Object? cause})
      : super('The market data request timed out. Please try again.', cause: cause);
}

class UnauthorizedException extends MarketApiException {
  const UnauthorizedException({int? statusCode})
      : super('Market data access is not configured for this environment.', statusCode: statusCode);
}

class RateLimitException extends MarketApiException {
  const RateLimitException({this.retryAfter, int? statusCode})
      : super('Updates are temporarily paused to respect the data provider limit.', statusCode: statusCode);

  final Duration? retryAfter;
}

class ServerException extends MarketApiException {
  const ServerException({int? statusCode})
      : super('Market data is temporarily unavailable. Please try again shortly.', statusCode: statusCode);
}

class ParsingException extends MarketApiException {
  const ParsingException({Object? cause})
      : super('The market data response could not be read safely.', cause: cause);
}

class UnknownApiException extends MarketApiException {
  const UnknownApiException({Object? cause, int? statusCode})
      : super('Unable to update market data right now.', statusCode: statusCode, cause: cause);
}

MarketApiException mapMarketError(Object error) {
  if (error is MarketApiException) return error;
  if (error is TimeoutException) return ApiTimeoutException(cause: error);
  return UnknownApiException(cause: error);
}
