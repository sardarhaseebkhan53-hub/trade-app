class MarketMemoryCache {
  final Map<String, _CacheEntry<Object?>> _entries =
      <String, _CacheEntry<Object?>>{};

  T? readFresh<T>(String key, Duration ttl, DateTime now) {
    final entry = _entries[key];
    if (entry == null ||
        now.difference(entry.savedAt) > ttl ||
        entry.value is! T) {
      return null;
    }
    return entry.value as T;
  }

  T? readAny<T>(String key) {
    final entry = _entries[key];
    if (entry == null || entry.value is! T) return null;
    return entry.value as T;
  }

  DateTime? savedAt(String key) => _entries[key]?.savedAt;

  void write<T>(String key, T value, DateTime now) {
    _entries[key] = _CacheEntry<Object?>(value, now);
  }

  void clear() => _entries.clear();
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.savedAt);

  final T value;
  final DateTime savedAt;
}
