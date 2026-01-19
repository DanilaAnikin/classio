import 'dart:collection';

/// A rate limiter service for protecting authentication endpoints.
/// Uses a sliding window approach to track attempts.
class RateLimiter {
  RateLimiter({
    this.maxAttempts = 5,
    this.windowDuration = const Duration(minutes: 15),
    this.lockoutDuration = const Duration(minutes: 30),
  });

  final int maxAttempts;
  final Duration windowDuration;
  final Duration lockoutDuration;

  final Map<String, Queue<DateTime>> _attempts = {};
  final Map<String, DateTime> _lockouts = {};

  /// Checks if the given key (e.g., email) is currently rate limited.
  /// Returns null if allowed, or the remaining lockout duration if blocked.
  Duration? checkRateLimit(String key) {
    final normalizedKey = key.toLowerCase().trim();
    _cleanupOldAttempts(normalizedKey);

    // Check if currently locked out
    final lockoutEnd = _lockouts[normalizedKey];
    if (lockoutEnd != null) {
      final remaining = lockoutEnd.difference(DateTime.now());
      if (remaining.isNegative) {
        _lockouts.remove(normalizedKey);
        _attempts.remove(normalizedKey);
        return null;
      }
      return remaining;
    }

    // Check attempt count
    final attempts = _attempts[normalizedKey]?.length ?? 0;
    if (attempts >= maxAttempts) {
      // Initiate lockout
      _lockouts[normalizedKey] = DateTime.now().add(lockoutDuration);
      return lockoutDuration;
    }

    return null;
  }

  /// Records an authentication attempt for the given key.
  void recordAttempt(String key) {
    final normalizedKey = key.toLowerCase().trim();
    _attempts.putIfAbsent(normalizedKey, () => Queue<DateTime>());
    _attempts[normalizedKey]!.add(DateTime.now());
  }

  /// Clears attempts for a key (call on successful authentication).
  void clearAttempts(String key) {
    final normalizedKey = key.toLowerCase().trim();
    _attempts.remove(normalizedKey);
    _lockouts.remove(normalizedKey);
  }

  /// Returns the number of remaining attempts for a key.
  int getRemainingAttempts(String key) {
    final normalizedKey = key.toLowerCase().trim();
    _cleanupOldAttempts(normalizedKey);
    final attempts = _attempts[normalizedKey]?.length ?? 0;
    return (maxAttempts - attempts).clamp(0, maxAttempts);
  }

  void _cleanupOldAttempts(String key) {
    final queue = _attempts[key];
    if (queue == null) return;

    final cutoff = DateTime.now().subtract(windowDuration);
    while (queue.isNotEmpty && queue.first.isBefore(cutoff)) {
      queue.removeFirst();
    }

    if (queue.isEmpty) {
      _attempts.remove(key);
    }
  }
}
