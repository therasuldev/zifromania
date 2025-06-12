// lib/data/cache/game_limit_service.dart
import 'dart:math';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/enums.dart';

enum SubscriptionType { free, oneMonth, threeMonths, sixMonths }

class GameLimitService {
  static const String _dailyRequestCountPrefix = 'daily_request_count_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';
  static const String _subscriptionTypePrefix = 'subscription_type_';

  // Subscription limits - günlük oyun limitləri
  static const Map<SubscriptionType, int> _subscriptionLimits = {
    SubscriptionType.free: 5, // 5 oyun per gün
    SubscriptionType.oneMonth: 15, // 15 oyun per gün
    SubscriptionType.threeMonths: 30, // 30 oyun per gün
    SubscriptionType.sixMonths: 50, // 50 oyun per gün
  };

  final SharedPreferences _prefs;
  late final String _deviceId;

  GameLimitService(this._prefs) {
    _initializeDeviceTracking();
  }

  // Cihaz izləməsini başlat
  void _initializeDeviceTracking() {
    _deviceId = _prefs.getString(_deviceIdPrefix) ?? _generateDeviceId();
    if (!_prefs.containsKey(_deviceIdPrefix)) {
      _prefs.setString(_deviceIdPrefix, _deviceId);
      _prefs.setInt(_installDatePrefix, DateTime.now().millisecondsSinceEpoch);
    }
  }

  // Abunəlik tipini təyin et
  Future<void> setSubscriptionType(SubscriptionType subscriptionType) async {
    await _prefs.setString(_subscriptionTypePrefix, subscriptionType.name);
  }

  // Abunəlik tipini al
  SubscriptionType getSubscriptionType() {
    final subscriptionName = _prefs.getString(_subscriptionTypePrefix);
    if (subscriptionName == null) return SubscriptionType.free;

    return SubscriptionType.values.firstWhere(
      (type) => type.name == subscriptionName,
      orElse: () => SubscriptionType.free,
    );
  }

  // İstifadəçinin abunə tipinə görə günlük limiti al
  int _getUserDailyLimit() {
    final subscriptionType = getSubscriptionType();
    return _subscriptionLimits[subscriptionType]!;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // Günlük oyun oynaya bilər-yoxdur yoxla
  bool canPlayGame(GameCategory category) {
    final dailyLimit = _getUserDailyLimit();
    final dailyRequests = getDailyRequestCount(category);
    return dailyRequests < dailyLimit;
  }

  // Günlük request sayını al
  int getDailyRequestCount(GameCategory category) {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Günlük request sayını artır
  Future<void> incrementDailyRequestCount(GameCategory category) async {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    final currentCount = getDailyRequestCount(category);
    await _prefs.setInt(todayKey, currentCount + 1);
  }

  // Günlük request sayaclarını təmizlə (admin üçün)
  Future<bool> clearDailyCounters(String adminCode) async {
    const correctAdminCode = "MATH_GAME_ADMIN_2024_CLEAR";
    if (adminCode != correctAdminCode) {
      return false;
    }

    for (GameCategory category in GameCategory.values) {
      final today = DateTime.now();
      final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
      await _prefs.remove(todayKey);
    }

    return true;
  }

  // Təhlükəsizlik statistikası
  Map<String, dynamic> getSecurityStats() {
    final installDate = _prefs.getInt(_installDatePrefix) ?? DateTime.now().millisecondsSinceEpoch;
    final daysSinceInstall = (DateTime.now().millisecondsSinceEpoch - installDate) / (24 * 60 * 60 * 1000);

    // Bütün kateqoriyalar üçün ümumi request sayını hesabla
    int totalRequests = 0;
    for (GameCategory category in GameCategory.values) {
      totalRequests += getDailyRequestCount(category);
    }

    final subscriptionType = getSubscriptionType();
    final dailyLimit = _getUserDailyLimit();

    return {
      'deviceId': '${_deviceId.substring(0, 8)}...', // Yalnız ilk 8 simvol
      'daysSinceInstall': daysSinceInstall.round(),
      'totalDailyRequests': totalRequests,
      'subscriptionType': subscriptionType.name,
      'dailyLimit': dailyLimit,
    };
  }

  // Kateqoriya üçün statistika
  Map<String, dynamic> getCategoryStats(GameCategory category) {
    final subscriptionType = getSubscriptionType();
    final dailyLimit = _getUserDailyLimit();
    final dailyRequests = getDailyRequestCount(category);

    return {
      'subscriptionType': subscriptionType.name,
      'dailyRequestCount': dailyRequests,
      'remainingDailyRequests': math.max(0, dailyLimit - dailyRequests),
      'canPlayGame': canPlayGame(category),
      'dailyLimit': dailyLimit,
    };
  }

  // Bütün kateqoriyalar üçün ümumi statistika
  Map<String, dynamic> getAllCategoriesStats() {
    final subscriptionType = getSubscriptionType();
    final dailyLimit = _getUserDailyLimit();

    int totalDailyRequests = 0;
    Map<String, Map<String, dynamic>> categoryStats = {};

    for (GameCategory category in GameCategory.values) {
      final dailyRequests = getDailyRequestCount(category);
      totalDailyRequests += dailyRequests;

      categoryStats[category.name] = {
        'dailyRequestCount': dailyRequests,
        'canPlayGame': canPlayGame(category),
      };
    }

    return {
      'subscriptionType': subscriptionType.name,
      'dailyLimit': dailyLimit,
      'totalDailyRequests': totalDailyRequests,
      'remainingDailyRequests': math.max(0, dailyLimit - totalDailyRequests),
      'categories': categoryStats,
    };
  }
}
