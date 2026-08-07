// lib/data/cache/game_limit_service.dart
import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:zifromania/services/shared_preferences_service.dart';
import '../../domain/entities/enums.dart';

enum SubscriptionType { free, oneMonth, threeMonths, sixMonths }

class GameLimitService {
  static const String _dailyRequestCountPrefix = 'daily_request_count_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';
  static const String _subscriptionTypePrefix = 'subscription_type_';

  // Flexible Games üçün key-lər
  static const String _flexibleGamesCountPrefix = 'flexible_games_count_';

  // Ümumi reklam sayğacları üçün key-lər
  static const String _globalAdWatchedCountPrefix = 'global_ad_watched_count_';
  static const String _globalAdRewardEarnedPrefix = 'global_ad_reward_earned_';

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

  final PrefsService _prefs;

  late final String _deviceId;

  // StreamController for each category
  final Map<GameCategory, StreamController<Map<String, int>>> _categoryControllers = {};

  GameLimitService({required PrefsService prefs}) : _prefs = prefs {
    _initializeDeviceTracking();

    // Create StreamControllers for each GameCategory
    for (var category in GameCategory.values) {
      _categoryControllers[category] = StreamController<Map<String, int>>.broadcast();
    }
  }

  // DEVICE TRACKING
  void _initializeDeviceTracking() {
    _deviceId = _prefs.getString(_deviceIdPrefix) ?? _generateDeviceId();
    if (!_prefs.containsKey(_deviceIdPrefix)) {
      _prefs.setString(_deviceIdPrefix, _deviceId);
      _prefs.setInt(_installDatePrefix, DateTime.now().millisecondsSinceEpoch);
    }
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // SUBSCRIPTION MANAGEMENT
  Future<void> setSubscriptionType(SubscriptionType subscriptionType) async {
    await _prefs.setString(_subscriptionTypePrefix, subscriptionType.name);

    // Bütün kateqoriyalar üçün stream-ləri yenilə
    for (var category in GameCategory.values) {
      _updateCategoryStream(category);
    }
  }

  SubscriptionType getSubscriptionType() {
    final subscriptionName = _prefs.getString(_subscriptionTypePrefix);
    if (subscriptionName == null) return SubscriptionType.free;

    return SubscriptionType.values.firstWhere(
      (type) => type.name == subscriptionName,
      orElse: () => SubscriptionType.free,
    );
  }

  // FLEXIBLE GAMES MANAGEMENT
  int getFlexibleGamesCount() {
    final today = DateTime.now();
    final todayKey = '$_flexibleGamesCountPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

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

  // GLOBAL AD SYSTEM
  int getGlobalAdWatchedCount() {
    final today = DateTime.now();
    final todayKey = '$_globalAdWatchedCountPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  bool hasEarnedGlobalAdRewardToday() {
    final today = DateTime.now();
    final todayKey = '$_globalAdRewardEarnedPrefix${today.year}_${today.month}_${today.day}';
    return _prefs.getBool(todayKey) ?? false;
  }

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

  Future<void> _applyGlobalAdReward() async {
    final today = DateTime.now();

    // Mükafat verildi olaraq işarələ
    final rewardEarnedKey = '$_globalAdRewardEarnedPrefix${today.year}_${today.month}_${today.day}';
    await _prefs.setBool(rewardEarnedKey, true);

    // 2 flexible game əlavə et
    await _addFlexibleGames(2);
  }

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

  bool canWatchAdForReward() {
    final watchedAds = getGlobalAdWatchedCount();
    final hasEarnedReward = hasEarnedGlobalAdRewardToday();
    return watchedAds < 3 && !hasEarnedReward;
  }

  // CATEGORY LIMIT MANAGEMENT - UPDATED WITH COIN SUPPORT
  Stream<Map<String, int>> getCategoryLimitStream(GameCategory category) {
    // İlk vəziyyəti göndər
    Future.delayed(Duration.zero, () {
      _updateCategoryStream(category);
    });

    return _categoryControllers[category]!.stream;
  }

  int getCategoryDailyLimit(GameCategory category) {
    final subscriptionType = getSubscriptionType();
    return _categoryLimits[subscriptionType]![category]!;
  }

  // UPDATED: Now accepts coin payment info
  bool canPlayGame(GameCategory category, {bool willPayWithCoin = false}) {
    final categoryLimit = getCategoryDailyLimit(category);
    final dailyRequests = getDailyRequestCount(category);
    final flexibleGames = getFlexibleGamesCount();

    // Normal limit, flexible games və ya coin payment
    return dailyRequests < categoryLimit || flexibleGames > 0 || willPayWithCoin;
  }

  int getDailyRequestCount(GameCategory category) {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  Future<void> incrementDailyRequestCount(GameCategory category) async {
    final today = DateTime.now();
    final todayKey = '$_dailyRequestCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    final currentCount = getDailyRequestCount(category);
    final newCount = currentCount + 1;
    await _prefs.setInt(todayKey, newCount);

    _updateCategoryStream(category);
  }

  void _updateCategoryStream(GameCategory category) async {
    final dailyRequests = getDailyRequestCount(category);
    final categoryLimit = getCategoryDailyLimit(category);
    final flexibleGames = getFlexibleGamesCount();

    // Əgər normal limit aşılıbsa, flexible games və ya coin payment istifadə edilə bilər
    final remainingNormalGames = math.max(0, categoryLimit - dailyRequests);

    _categoryControllers[category]?.add({
      'current': dailyRequests,
      'limit': categoryLimit,
      'flexibleGames': flexibleGames,
      'remainingNormal': remainingNormalGames,
    });
  }

  // GAME PLAY LOGIC - UPDATED WITH COIN SUPPORT
  Future<void> playGame(GameCategory category, {bool paidWithCoin = false}) async {
    final canPlay = canPlayGame(category, willPayWithCoin: paidWithCoin);
    if (!canPlay) {
      throw Exception('Bu kateqoriya üçün oyun oynamaq mümkün deyil. Limitlər aşılıb və kifayət qədər coin yoxdur.');
    }

    final dailyRequests = getDailyRequestCount(category);
    final categoryLimit = getCategoryDailyLimit(category);
    final flexibleGames = getFlexibleGamesCount();

    if (dailyRequests < categoryLimit) {
      // Normal limitdə oynamaq - counter artır
      await incrementDailyRequestCount(category);
    } else if (flexibleGames > 0) {
      // Flexible game istifadə etmək - counter artırmır
      await useFlexibleGame();
    } else if (paidWithCoin) {
      // Coin ilə ödəmə - counter artırmır
      // Burada coin deduction logic-i olacaq (başqa service-də)
      // Yalnız GameLimitService-dən keçməsinə icazə veririk
    }
  }

  // ADMIN & MAINTENANCE
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

  // STATISTICS
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

  Future<Map<String, dynamic>> getAllCategoriesStats() async {
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
