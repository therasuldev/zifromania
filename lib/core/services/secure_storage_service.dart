import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<bool> write<T>(String key, T value) async {
    try {
      if (value == null) {
        await delete(key);
        return true;
      }

      final String encoded;

      if (value is String) {
        encoded = value;
      } else if (value is int || value is double || value is bool) {
        encoded = value.toString();
      } else {
        encoded = jsonEncode(value);
      }

      await _storage.write(
        key: key,
        value: encoded,
      );

      return true;
    } catch (e) {
      // logger istifadə etmək daha yaxşıdır
      return false;
    }
  }

  Future<T?> read<T>(String key) async {
    try {
      final stored = await _storage.read(key: key);

      if (stored == null || stored.isEmpty) {
        return null;
      }

      if (T == String) {
        return stored as T;
      }

      if (T == int) {
        return int.tryParse(stored) as T?;
      }

      if (T == double) {
        return double.tryParse(stored) as T?;
      }

      if (T == bool) {
        return (stored == 'true') as T;
      }

      final decoded = jsonDecode(stored);

      return decoded as T;
    } catch (e) {
      await delete(key);
      return null;
    }
  }

  Future<bool> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (_) {
      return {};
    }
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});
