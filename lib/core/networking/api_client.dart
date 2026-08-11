/// Contract for a future authenticated API client. Phase 3 repositories are mock-backed.
abstract interface class ApiClient {
  Future<Map<String, Object?>> get(String path, {Map<String, String>? query});
  Future<Map<String, Object?>> post(String path, {Object? body});
}
