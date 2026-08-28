import 'dart:convert';
import 'package:zifromania/core/services/secure_storage_service.dart';

import '../models/user_model.dart';
import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl({
    required SecureStorageService storage,
  }) : _storage = storage;

  final SecureStorageService _storage;

  static const userKey = 'user';

  @override
  Future<UserModel?> getUser() async {
    try {
      final stored = await _storage.read<String>(userKey);

      if (stored == null || stored.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(stored);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return UserModel.fromMap(decoded);
    } catch (_) {
      await _storage.delete(userKey);
      return null;
    }
  }

  @override
  Future<bool> cacheUser(UserModel user) async {
    final result = await _storage.write(userKey, user.toMap());

    return result;
  }

  @override
  Future<bool> clearUser() async {
    final result = await _storage.delete(userKey);

    return result;
  }
}
