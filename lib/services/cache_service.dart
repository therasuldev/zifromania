import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zifromania/models/subscription_model.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/models/game_stats.dart';

class SecureCacheService {
  final _storage = const FlutterSecureStorage();
  final ValueNotifier<UserModel?> userNotifier = ValueNotifier(null);

  /// Writes data securely with better error handling
  Future<bool> write<T>(String key, T value) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
        return true;
      }

      String toStore;

      if (value is String) {
        toStore = value;
      } else if (value is int || value is double || value is bool) {
        toStore = value.toString();
      } else if (value is UserModel) {
        toStore = jsonEncode(value.toMap());
        userNotifier.value = value;
      } else {
        toStore = jsonEncode(value);
      }

      await _storage.write(key: key, value: toStore);
      return true;
    } catch (e) {
      print('Error writing to secure storage for key $key: $e');
      return false;
    }
  }

  /// Reads data with improved error handling and type conversion
  Future<T?> read<T>(String key) async {
    try {
      final String? stored = await _storage.read(key: key);
      if (stored == null || stored.isEmpty) return null;

      // Handle primitive types
      if (T == String) return stored as T;
      if (T == int) return int.tryParse(stored) as T?;
      if (T == double) return double.tryParse(stored) as T?;
      if (T == bool) return (stored == 'true') as T;

      // Decode JSON for objects
      final Map<String, dynamic> decoded = jsonDecode(stored);

      // Special handling for UserModel
      if (T == UserModel) {
        final user = _createUserModelFromMap(decoded);
        userNotifier.value = user;
        return user as T?;
      }

      // Generic case
      return decoded as T;
    } catch (e) {
      print('Error reading from secure storage for key $key: $e');
      // Auto-delete corrupted data
      await delete(key);
      return null;
    }
  }

  /// Creates UserModel from map with comprehensive validation
  UserModel? _createUserModelFromMap(Map<String, dynamic> map) {
    try {
      // Validate required fields
      if (!map.containsKey('uid') || map['uid'] == null || map['uid'].toString().isEmpty) {
        print('Invalid UserModel data: missing or empty uid');
        return null;
      }

      return UserModel(
        uid: map['uid'].toString(),
        displayName: map['displayName']?.toString(),
        email: map['email']?.toString(),
        photoURL: map['photoURL']?.toString(),
        coins: _parseInt(map['coins'], 0),
        level: _parseInt(map['level'], 1),
        xp: _parseInt(map['xp'], 0),
        xpForNextLevel: _parseInt(map['xpForNextLevel'], 1000),
        hasActiveSubscription: _parseBool(map['hasActiveSubscription'], false),
        achievements: _parseStringList(map['achievements']),
        completedTasks: _parseStringList(map['completedTasks']),
        subscription: _parseSubscription(map['subscription']),
        playedDates: _parseStringList(map['playedDates']),
        currentStreak: _parseInt(map['currentStreak'], 0),
        longestStreak: _parseInt(map['longestStreak'], 0),
        gameStats: _parseGameStats(map['gameStats']),
      );
    } catch (e) {
      print('Error creating UserModel from cached data: $e');
      return null;
    }
  }

  // Helper methods for safe parsing
  int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool _parseBool(dynamic value, bool defaultValue) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  SubscriptionModel _parseSubscription(dynamic value) {
    if (value is Map<String, dynamic>) {
      return SubscriptionModel.fromMap(value);
    }
    return const SubscriptionModel();
  }

  GameStats _parseGameStats(dynamic value) {
    if (value is Map<String, dynamic>) {
      return GameStats.fromMap(value);
    }
    return const GameStats();
  }

  /// Deletes a specific key
  Future<bool> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      print('Error deleting key $key: $e');
      return false;
    }
  }

  /// Clears all stored data
  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      print('Error checking key existence: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('Error reading all data: $e');
      return {};
    }
  }

  /// Azaldılmış coin miqdarı ilə istifadəçini yenilə
  Future<(bool, String)> decreaseUserCoins(int amount) async {
    if (amount <= 0) return (false, '');
    final user = await read<UserModel>('user');
    if (user == null) return (false, '');

    final newCoins = (user.coins - amount).clamp(0, double.infinity).toInt(); // mənfi olmasın
    final updatedUser = user.copyWith(coins: newCoins);
    return (await write<UserModel>('user', updatedUser), user.uid);
  }

  /// Artırılmış coin miqdarı ilə istifadəçini yenilə
  Future<(bool, String)> increaseUserCoins(int amount) async {
    if (amount <= 0) return (false, '');
    final user = await read<UserModel>('user');
    if (user == null) return (false, '');

    final newCoins = user.coins + amount;
    final updatedUser = user.copyWith(coins: newCoins);
    return (await write<UserModel>('user', updatedUser), user.uid);
  }
}
