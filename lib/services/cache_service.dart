import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zifromania/models/subscription_model.dart';
import 'package:zifromania/models/user_model.dart';

class SecureCacheService {
  // Uses Keychain on iOS, EncryptedSharedPreferences on Android
  final _storage = const FlutterSecureStorage();

  /// Writes data securely. Handles primitive types directly and serializes objects.
  Future<void> write<T>(String key, T value) async {
    if (value == null) {
      await _storage.delete(key: key);
      return;
    }

    String toStore;

    if (value is String) {
      toStore = value;
    } else if (value is int || value is double || value is bool) {
      toStore = value.toString();
    } else if (value is UserModel) {
      // Special handling for UserModel
      toStore = jsonEncode(value.toMap());
    } else {
      // Generic object serialization
      toStore = jsonEncode(value);
    }

    await _storage.write(key: key, value: toStore);
  }

  /// Reads data and converts to appropriate type.
  Future<T?> read<T>(String key) async {
    final String? stored = await _storage.read(key: key);
    if (stored == null || stored.isEmpty) return null;

    // Handle primitive types
    if (T == String) return stored as T;
    if (T == int) return int.tryParse(stored) as T?;
    if (T == double) return double.tryParse(stored) as T?;
    if (T == bool) return (stored == 'true') as T;

    try {
      // Decode JSON for objects
      final Map<String, dynamic> decoded = jsonDecode(stored);

      // Special handling for UserModel
      if (T == UserModel) {
        // Validate required fields
        if (!decoded.containsKey('uid') || decoded['uid'] == null || decoded['uid'].toString().isEmpty) {
          print('Invalid UserModel data in cache: missing or empty uid');
          return null;
        }

        try {
          return UserModel(
            uid: decoded['uid'],
            displayName: decoded['displayName'],
            email: decoded['email'],
            photoURL: decoded['photoURL'],
            xp: decoded['xp'] is int ? decoded['xp'] : 0,
            xpForNextLevel: decoded['xpForNextLevel'] is int ? decoded['xpForNextLevel'] : 1000,
            level: decoded['level'] is int ? decoded['level'] : 0,
            achievements: (decoded['achievements'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
            subscription: decoded['subscription'] != null ? SubscriptionModel.fromMap(decoded['subscription']) : const SubscriptionModel(),
            coins: decoded['coins'] is int ? decoded['coins'] : 0,
            hasActiveSubscription: decoded['hasActiveSubscription'] is bool ? decoded['hasActiveSubscription'] : false,
          ) as T;
        } catch (e) {
          print('Error creating UserModel from cached data: $e');
          return null;
        }
      }

      // Generic case (might need factory constructors for other types)
      return decoded as T;
    } catch (e) {
      print('Error decoding stored data for key $key: $e');
      // Auto-delete corrupted data
      await delete(key);
      return null;
    }
  }

  /// Deletes a specific key
  Future<void> delete(String key) => _storage.delete(key: key);

  /// Clears all stored data
  Future<void> clearAll() => _storage.deleteAll();
}
