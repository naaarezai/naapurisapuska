import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Utility class for retrying operations with exponential backoff.
class RetryUtils {
  /// Retries the given [action] a [maxAttempts] number of times.
  /// Uses exponential backoff with a [delay].
  static Future<T> retry<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Object)? retryIf,
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        return await action();
      } catch (e) {
        if (attempts >= maxAttempts || (retryIf != null && !retryIf(e))) {
          rethrow;
        }

        // Exponential backoff: delay * 2^(attempts-1)
        final nextDelay = delay * pow(2, attempts - 1);

        if (kDebugMode) {
          print(
              '⚠️ Operation failed (attempt $attempts). Retrying in ${nextDelay.inSeconds}s... Error: $e');
        }

        await Future.delayed(nextDelay);
      }
    }
  }
}
