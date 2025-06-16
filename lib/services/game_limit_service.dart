// lib/data/cache/game_limit_service.dart
import 'dart:async';
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

  // Flexible Games üçün yeni key-lər
  static const String _flexibleGamesCountPrefix = 'flexible_games_count_';

  // Ümumi reklam sayğacları üçün key-lər
  static const String _globalAdWatchedCountPrefix = 'global_ad_watched_count_';
  static const String _globalAdRewardEarnedPrefix = 'global_ad_reward_earned_';

  // Bugün neçə flexible game var
  int getFlexibleGamesCount() {
    final today = DateTime.now();
    final todayKey = '$_flexibleGamesCountPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Flexible game istifadə et
  Future<void> useFlexibleGame() async {
    final flexibleGames = getFlexibleGamesCount();
    if (flexibleGames > 0) {
      final today = DateTime.now();
      final todayKey = '$_flexibleGamesCountPrefix${today.year}_${today.month}_${today.day}';
      await _prefs.setInt(todayKey, flexibleGames - 1);

      // Bütün kateqoriya stream-lərini yenilə
      for (var category in GameCategory.values) {
        _updateCategoryStream(category);
      }
    }
  }

  // Flexible games əlavə et
  Future<void> _addFlexibleGames(int count) async {
    final today = DateTime.now();
    final todayKey = '$_flexibleGamesCountPrefix${today.year}_${today.month}_${today.day}';
    final currentGames = getFlexibleGamesCount();
    final newGames = currentGames + count;
    await _prefs.setInt(todayKey, newGames);

    // Bütün kateqoriya stream-lərini yenilə
    for (var category in GameCategory.values) {
      _updateCategoryStream(category);
    }
  }

  // Bugün neçə reklam izlənib (ümumi)
  int getGlobalAdWatchedCount() {
    final today = DateTime.now();
    final todayKey = '$_globalAdWatchedCountPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Bugün ümumi reklam mükafatı qazanılıbmı?
  bool hasEarnedGlobalAdRewardToday() {
    final today = DateTime.now();
    final todayKey = '$_globalAdRewardEarnedPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getBool(todayKey) ?? false;
  }

  // Ümumi reklam izləməsini qeyd et
  Future<void> incrementGlobalAdWatchedCount() async {
    final today = DateTime.now();
    final todayKey = '$_globalAdWatchedCountPrefix${today.year}_${today.month}_${today.day}';
    final currentCount = getGlobalAdWatchedCount();
    final newCount = currentCount + 1;
    await _prefs.setInt(todayKey, newCount);

    // 3 reklam izlədikdən sonra 3 flexible game ver
    if (newCount >= 3 && !hasEarnedGlobalAdRewardToday()) {
      await _applyGlobalAdReward();
    }
  }

  // 3 flexible game mükafatı ver
  Future<void> _applyGlobalAdReward() async {
    final today = DateTime.now();

    // Mükafat verildi olaraq işarələ
    final rewardEarnedKey = '$_globalAdRewardEarnedPrefix${today.year}_${today.month}_${today.day}';
    await _prefs.setBool(rewardEarnedKey, true);

    // 3 flexible game əlavə et
    await _addFlexibleGames(3);
  }

  // Ümumi reklam vəziyyətini al
  Map<String, dynamic> getGlobalAdStatus() {
    final watchedAds = getGlobalAdWatchedCount();
    final hasEarnedReward = hasEarnedGlobalAdRewardToday();
    final remainingAds = hasEarnedReward ? 0 : (3 - watchedAds);
    final flexibleGames = getFlexibleGamesCount();

    return {
      'watchedAds': watchedAds,
      'maxAds': 3,
      'remainingAds': remainingAds.clamp(0, 3),
      'hasEarnedReward': hasEarnedReward,
      'canWatchMore': watchedAds < 3 && !hasEarnedReward,
      'flexibleGames': flexibleGames,
    };
  }

  // Reklam izləyə bilər-yoxdur yoxla
  bool canWatchAdForReward() {
    final watchedAds = getGlobalAdWatchedCount();
    final hasEarnedReward = hasEarnedGlobalAdRewardToday();
    return watchedAds < 3 && !hasEarnedReward;
  }

  // Hər kateqoriya üçün abunəlik tipi əsasında limit
  static const Map<SubscriptionType, Map<GameCategory, int>> _categoryLimits = {
    SubscriptionType.free: {
      GameCategory.quickThinking: 3,
      GameCategory.multiplyDivide: 3,
      GameCategory.trueOrFalse: 3,
      GameCategory.expert: 2,
      GameCategory.training: 1,
    },
    SubscriptionType.oneMonth: {
      GameCategory.quickThinking: 5,
      GameCategory.multiplyDivide: 5,
      GameCategory.trueOrFalse: 5,
      GameCategory.expert: 3,
      GameCategory.training: 2,
    },
    SubscriptionType.threeMonths: {
      GameCategory.quickThinking: 10,
      GameCategory.multiplyDivide: 10,
      GameCategory.trueOrFalse: 10,
      GameCategory.expert: 5,
      GameCategory.training: 4,
    },
    SubscriptionType.sixMonths: {
      GameCategory.quickThinking: 20,
      GameCategory.multiplyDivide: 20,
      GameCategory.trueOrFalse: 20,
      GameCategory.expert: 15,
      GameCategory.training: 10,
    },
  };

  final SharedPreferences _prefs;
  late final String _deviceId;

  // StreamController for each category
  final Map<GameCategory, StreamController<Map<String, int>>> _categoryControllers = {};

  GameLimitService(this._prefs) {
    _initializeDeviceTracking();

    // Create StreamControllers for each GameCategory
    for (var category in GameCategory.values) {
      _categoryControllers[category] = StreamController<Map<String, int>>.broadcast();
    }
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

    // Bütün kateqoriyalar üçün stream-ləri yenilə
    for (var category in GameCategory.values) {
      _updateCategoryStream(category);
    }
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

  // Stream qaytaran metod
  Stream<Map<String, int>> getCategoryLimitStream(GameCategory category) {
    // İlk vəziyyəti göndər
    Future.delayed(Duration.zero, () {
      _updateCategoryStream(category);
    });

    return _categoryControllers[category]!.stream;
  }

  // Kateqoriya üçün günlük limiti al
  int getCategoryDailyLimit(GameCategory category) {
    final subscriptionType = getSubscriptionType();
    return _categoryLimits[subscriptionType]![category]!;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // Kateqoriya üçün oyun oynaya bilər-yoxdur yoxla (YENİ LOQIKA)
  bool canPlayGame(GameCategory category) {
    final categoryLimit = getCategoryDailyLimit(category);
    final dailyRequests = getDailyRequestCount(category);
    final flexibleGames = getFlexibleGamesCount();

    // Normal limitdən əlavə flexible games də var
    return dailyRequests < categoryLimit || flexibleGames > 0;
  }

  // Kateqoriya üçün günlük request sayını al
  int getDailyRequestCount(GameCategory category) {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Kateqoriya üçün günlük request sayını artır
  Future<void> incrementDailyRequestCount(GameCategory category) async {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    final currentCount = getDailyRequestCount(category);
    final newCount = currentCount + 1;
    await _prefs.setInt(todayKey, newCount);

    _updateCategoryStream(category);
  }

  // Kateqoriya stream-ini yenilə (YENİ LOQIKA)
  void _updateCategoryStream(GameCategory category) {
    final dailyRequests = getDailyRequestCount(category);
    final categoryLimit = getCategoryDailyLimit(category);
    final flexibleGames = getFlexibleGamesCount();

    // Əgər normal limit aşılıbsa, flexible games istifadə edilə bilər
    final remainingNormalGames = math.max(0, categoryLimit - dailyRequests);
    final totalAvailableGames = remainingNormalGames + flexibleGames;

    _categoryControllers[category]?.add({
      'current': dailyRequests,
      'limit': categoryLimit,
      'flexibleGames': flexibleGames,
      'remainingNormal': remainingNormalGames,
      'totalAvailable': totalAvailableGames,
    });
  }

  // Admin üçün günlük sayğacları təmizlə (YENİ)
  Future<bool> clearDailyCounters(String adminCode) async {
    const correctAdminCode = "MATH_GAME_ADMIN_2024_CLEAR";
    if (adminCode != correctAdminCode) {
      return false;
    }

    final today = DateTime.now();

    // Flexible games təmizlə
    final flexibleGamesKey = '$_flexibleGamesCountPrefix${today.year}_${today.month}_${today.day}';
    await _prefs.remove(flexibleGamesKey);

    // Ümumi reklam sayğaclarını təmizlə
    final globalAdWatchedKey = '$_globalAdWatchedCountPrefix${today.year}_${today.month}_${today.day}';
    final globalAdRewardKey = '$_globalAdRewardEarnedPrefix${today.year}_${today.month}_${today.day}';
    await _prefs.remove(globalAdWatchedKey);
    await _prefs.remove(globalAdRewardKey);

    for (GameCategory category in GameCategory.values) {
      // Request counter təmizlə
      final requestKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
      await _prefs.remove(requestKey);

      // Stream-ləri yenilə
      _updateCategoryStream(category);
    }

    return true;
  }

  // Oyun oynandıqda çağrılacaq metod (YENİ LOQIKA)
  Future<void> playGame(GameCategory category) async {
    if (!canPlayGame(category)) {
      throw Exception('Bu kateqoriya üçün oyun limiti aşılıb');
    }

    final dailyRequests = getDailyRequestCount(category);
    final categoryLimit = getCategoryDailyLimit(category);

    if (dailyRequests < categoryLimit) {
      // Normal limitdə oynamaq - counter artır
      await incrementDailyRequestCount(category);
    } else {
      // Flexible game istifadə etmək - counter artırmır
      await useFlexibleGame();
    }
  }

  // Təhlükəsizlik statistikası (YENİ)
  Map<String, dynamic> getSecurityStats() {
    final installDate = _prefs.getInt(_installDatePrefix) ?? DateTime.now().millisecondsSinceEpoch;
    final daysSinceInstall = (DateTime.now().millisecondsSinceEpoch - installDate) / (24 * 60 * 60 * 1000);

    // Bütün kateqoriyalar üçün ümumi request sayını hesabla
    int totalRequests = 0;
    for (GameCategory category in GameCategory.values) {
      totalRequests += getDailyRequestCount(category);
    }

    final subscriptionType = getSubscriptionType();
    final globalAdStatus = getGlobalAdStatus();

    return {
      'deviceId': '${_deviceId.substring(0, 8)}...', // Yalnız ilk 8 simvol
      'daysSinceInstall': daysSinceInstall.round(),
      'totalDailyRequests': totalRequests,
      'flexibleGamesAvailable': getFlexibleGamesCount(),
      'subscriptionType': subscriptionType.name,
      'globalAdStatus': globalAdStatus,
    };
  }

  // Kateqoriya üçün statistika (YENİ)
  Map<String, dynamic> getCategoryStats(GameCategory category) {
    final subscriptionType = getSubscriptionType();
    final categoryLimit = getCategoryDailyLimit(category);
    final dailyRequests = getDailyRequestCount(category);
    final flexibleGames = getFlexibleGamesCount();
    final remainingNormal = math.max(0, categoryLimit - dailyRequests);

    return {
      'subscriptionType': subscriptionType.name,
      'categoryName': category.name,
      'dailyRequestCount': dailyRequests,
      'categoryLimit': categoryLimit,
      'flexibleGamesAvailable': flexibleGames,
      'remainingNormalGames': remainingNormal,
      'canPlayGame': canPlayGame(category),
      'totalAvailableGames': remainingNormal + flexibleGames,
    };
  }

  // Bütün kateqoriyalar üçün statistika (YENİ)
  Map<String, dynamic> getAllCategoriesStats() {
    final subscriptionType = getSubscriptionType();
    final flexibleGames = getFlexibleGamesCount();

    int totalDailyRequests = 0;
    int totalDailyLimits = 0;
    Map<String, Map<String, dynamic>> categoryStats = {};

    for (GameCategory category in GameCategory.values) {
      final dailyRequests = getDailyRequestCount(category);
      final categoryLimit = getCategoryDailyLimit(category);
      final remainingNormal = math.max(0, categoryLimit - dailyRequests);

      totalDailyRequests += dailyRequests;
      totalDailyLimits += categoryLimit;

      categoryStats[category.name] = {
        'dailyRequestCount': dailyRequests,
        'categoryLimit': categoryLimit,
        'remainingNormalGames': remainingNormal,
        'canPlayGame': canPlayGame(category),
        'totalAvailableGames': remainingNormal + flexibleGames,
      };
    }

    return {
      'subscriptionType': subscriptionType.name,
      'totalDailyRequests': totalDailyRequests,
      'totalDailyLimits': totalDailyLimits,
      'flexibleGamesAvailable': flexibleGames,
      'totalRemainingNormalGames': math.max(0, totalDailyLimits - totalDailyRequests),
      'categories': categoryStats,
    };
  }

  // Bütün kateqoriya limitlərini al
  Map<GameCategory, int> getAllCategoryLimits() {
    final subscriptionType = getSubscriptionType();
    return Map<GameCategory, int>.from(_categoryLimits[subscriptionType]!);
  }

  void dispose() {
    for (var controller in _categoryControllers.values) {
      controller.close();
    }
  }
}
