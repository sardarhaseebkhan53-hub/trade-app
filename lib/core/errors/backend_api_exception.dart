class BackendApiException implements Exception {
  const BackendApiException(this.code, this.userMessage, {this.statusCode});
  final String code;
  final String userMessage;
  final int? statusCode;
}

class BackendUnauthorizedException extends BackendApiException {
  const BackendUnauthorizedException()
      : super('AUTH_SESSION_EXPIRED', 'Your session has ended. Please sign in again.', statusCode: 401);
}
