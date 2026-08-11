sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Unable to load market data.']);
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Your session has ended.']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure([super.message = 'Please review the highlighted fields.']);
}

class ServiceFailure extends AppFailure {
  const ServiceFailure([super.message = 'The service is temporarily unavailable.']);
}
