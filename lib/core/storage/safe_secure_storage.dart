import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SafeSecureStorage {
  const SafeSecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<void> _queue = Future<void>.value();

  static Future<String?> read(String key) async {
    await _queue.catchError((_) {});

    for (var attempt = 0; attempt < 3; attempt += 1) {
      try {
        return await _storage.read(key: key);
      } catch (error) {
        if (_isTransientStorageLock(error) && attempt < 2) {
          await _delayForRetry(attempt);
          continue;
        }

        debugPrint('[M5 Storage] read "$key" ignored safely: $error');
        return null;
      }
    }

    return null;
  }

  static Future<void> write({
    required String key,
    required String value,
  }) {
    return _enqueue(
      () => _storage.write(key: key, value: value),
      action: 'write',
      key: key,
    );
  }

  static Future<void> delete(String key) {
    return _enqueue(
      () => _storage.delete(key: key),
      action: 'delete',
      key: key,
    );
  }

  static Future<void> _enqueue(
    Future<void> Function() operation, {
    required String action,
    required String key,
  }) {
    final queued = _queue
        .catchError((_) {})
        .then((_) => _runMutation(operation, action: action, key: key));
    _queue = queued.catchError((_) {});
    return queued;
  }

  static Future<void> _runMutation(
    Future<void> Function() operation, {
    required String action,
    required String key,
  }) async {
    for (var attempt = 0; attempt < 3; attempt += 1) {
      try {
        await operation();
        return;
      } catch (error) {
        if (_isTransientStorageLock(error) && attempt < 2) {
          await _delayForRetry(attempt);
          continue;
        }

        debugPrint('[M5 Storage] $action "$key" ignored safely: $error');
        return;
      }
    }
  }

  static Future<void> _delayForRetry(int attempt) {
    return Future<void>.delayed(Duration(milliseconds: 70 * (attempt + 1)));
  }

  static bool _isTransientStorageLock(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('pathaccessexception') ||
        message.contains('being used by another process') ||
        message.contains('cannot access the file') ||
        message.contains('errno = 32');
  }
}
