import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final class PreferencesService {
  SharedPreferences? _prefs;

  /// Initialize the preferences service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Generic set method
  Future<bool> _setValue<T>(String key, T value) async {
    switch (T) {
      case const (String):
        return await _prefs?.setString(key, value as String) ?? false;
      case const (int):
        return await _prefs?.setInt(key, value as int) ?? false;
      case const (bool):
        return await _prefs?.setBool(key, value as bool) ?? false;
      case const (double):
        return await _prefs?.setDouble(key, value as double) ?? false;
      default:
        if (value is List<String>) {
          return await _prefs?.setStringList(key, value) ?? false;
        }
        return await _prefs?.setString(key, json.encode(value)) ?? false;
    }
  }

  /// Generic get method
  T? _getValue<T>(String key) {
    switch (T) {
      case const (String):
        return _prefs?.getString(key) as T?;
      case const (int):
        return _prefs?.getInt(key) as T?;
      case const (bool):
        return _prefs?.getBool(key) as T?;
      case const (double):
        return _prefs?.getDouble(key) as T?;
      default:
        if (T == List<String>) {
          return _prefs?.getStringList(key) as T?;
        }
        final jsonStr = _prefs?.getString(key);
        return jsonStr != null ? json.decode(jsonStr) as T? : null;
    }
  }

  // Public API methods
  Future<bool> setString(String key, String value) => _setValue(key, value);
  Future<bool> setInt(String key, int value) => _setValue(key, value);
  Future<bool> setBool(String key, bool value) => _setValue(key, value);
  Future<bool> setDouble(String key, double value) => _setValue(key, value);
  Future<bool> setStringList(String key, List<String> value) => _setValue(key, value);
  Future<bool> setObject(String key, Map<String, dynamic> value) => _setValue(key, value);

  String? getString(String key) => _getValue<String>(key);
  int? getInt(String key) => _getValue<int>(key);
  bool? getBool(String key) => _getValue<bool>(key);
  double? getDouble(String key) => _getValue<double>(key);
  List<String>? getStringList(String key) => _getValue<List<String>>(key);
  Map<String, dynamic>? getObject(String key) => _getValue<Map<String, dynamic>>(key);

  // Utility methods
  Future<bool> remove(String key) async => await _prefs?.remove(key) ?? false;
  Future<bool> clear() async => await _prefs?.clear() ?? false;
  bool containsKey(String key) => _prefs?.containsKey(key) ?? false;
  Set<String> getKeys() => _prefs?.getKeys() ?? {};

  /// Get value with default fallback
  T getValue<T>(String key, T defaultValue) => _getValue<T>(key) ?? defaultValue;
}