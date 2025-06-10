// lib/data/cache/question_cache_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/math_question.dart';

enum SubscriptionType { free, oneMonth, threeMonths, sixMonths }

class QuestionCacheService {
  static const String _cachePrefix = 'cached_questions_';
  static const String _apiCallCountPrefix = 'api_call_count_'; // Hər kateqoriya üçün API çağırışı sayacı
  static const String _dailyGameCountPrefix = 'daily_game_count_'; // Günlük oyun sayacı
  static const String _lastClearPrefix = 'last_clear_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';
  static const String _subscriptionTypePrefix = 'subscription_type_';

  // Free user limits
  static const int _freeMaxApiCallsPerCategory = 4;
  static const int _freeMaxGamesPerCategoryDaily = 0; // Free userlar unlimited amma API limiti var

  // Subscription limits
  static const Map<SubscriptionType, Map<String, int>> _subscriptionLimits = {
    SubscriptionType.free: {
      'maxApiCallsPerCategory': 3,
      'maxGamesPerCategoryDaily': 5, // 3 API + 2 keş = 5 oyun
    },
    SubscriptionType.oneMonth: {
      'maxApiCallsPerCategory': 5,
      'maxGamesPerCategoryDaily': 9, // 5 API + 4 keş = 9 oyun
    },
    SubscriptionType.threeMonths: {
      'maxApiCallsPerCategory': 8,
      'maxGamesPerCategoryDaily': 12, // 9 API + 3 keş = 12 oyun
    },
    SubscriptionType.sixMonths: {
      'maxApiCallsPerCategory': 15,
      'maxGamesPerCategoryDaily': 25, // 15 API + 10 keş = 25 oyun
    },
  };

  static const int _questionsPerGame = 50; // Hər oyunda 50 sual
  static const int _minHoursBetweenClears = 24; // Keş silmə arası minimum 24 saat

  final SharedPreferences _prefs;
  late final String _deviceId;

  QuestionCacheService(this._prefs) {
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

  // İstifadəçinin abunə tipinə görə limitləri al
  Map<String, int> _getUserLimits() {
    final subscriptionType = getSubscriptionType();
    return _subscriptionLimits[subscriptionType]!;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // Kateqoriya üçün API çağırışı limitini yoxla
  bool canMakeApiCall(GameCategory category) {
    final userLimits = _getUserLimits();
    final apiCallCount = getCategoryApiCallCount(category);
    return apiCallCount < userLimits['maxApiCallsPerCategory']!;
  }

  // Günlük oyun limitini yoxla
  bool canPlayGame(GameCategory category) {
    final subscriptionType = getSubscriptionType();

    // Free userlar üçün yalnız API limiti var
    if (subscriptionType == SubscriptionType.free) {
      return canMakeApiCall(category) || hasSufficientCachedQuestions(category);
    }

    // Premium userlar üçün günlük oyun limiti
    final userLimits = _getUserLimits();
    final dailyGames = getDailyGameCount(category);
    return dailyGames < userLimits['maxGamesPerCategoryDaily']!;
  }

  // Günlük oyun sayını al
  int getDailyGameCount(GameCategory category) {
    final today = DateTime.now();
    final todayKey = '$_dailyGameCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Günlük oyun sayını artır
  Future<void> incrementDailyGameCount(GameCategory category) async {
    final today = DateTime.now();
    final todayKey = '$_dailyGameCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
    final currentCount = getDailyGameCount(category);
    await _prefs.setInt(todayKey, currentCount + 1);
  }

  // Kateqoriya üçün API çağırışı sayını al
  int getCategoryApiCallCount(GameCategory category) {
    return _prefs.getInt('$_apiCallCountPrefix${category.name}') ?? 0;
  }

  // Kateqoriya üçün API çağırışı sayını artır
  Future<void> incrementCategoryApiCallCount(GameCategory category) async {
    final currentCount = getCategoryApiCallCount(category);
    await _prefs.setInt('$_apiCallCountPrefix${category.name}', currentCount + 1);
  }

  // Kateqoriya üçün keşdə kifayət qədər sual var-yoxdur yoxla
  bool hasSufficientCachedQuestions(GameCategory category) {
    final cachedQuestions = getCachedQuestions(category);
    return cachedQuestions.length >= _questionsPerGame;
  }

  // API-dən alınan sualları keşə əlavə et
  Future<void> addQuestionsToCache(GameCategory category, List<MathQuestion> questions) async {
    final existingQuestions = getCachedQuestions(category);
    existingQuestions.addAll(questions);

    // JSON formatında saxla
    final questionsJson = existingQuestions
        .map((q) => {
              'question': q.question,
              'correctAnswer': q.correctAnswer,
              'answerOptions': q.answerOptions,
            })
        .toList();

    await _prefs.setString('$_cachePrefix${category.name}', json.encode(questionsJson));
  }

  // Keşdən sualları al
  List<MathQuestion> getCachedQuestions(GameCategory category) {
    final cachedData = _prefs.getString('$_cachePrefix${category.name}');
    if (cachedData == null) return [];

    try {
      final List<dynamic> questionsJson = json.decode(cachedData);
      return questionsJson
          .map((q) => MathQuestion(
                question: q['question'],
                correctAnswer: q['correctAnswer'],
                answerOptions: Map<String, String>.from(q['answerOptions']),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Keşdən qarışdırılmış suallar al
  List<MathQuestion> getShuffledQuestionsFromCache(GameCategory category, int count) {
    final allCachedQuestions = getCachedQuestions(category);
    if (allCachedQuestions.length < count) {
      return allCachedQuestions..shuffle();
    }

    // Qarışdır və lazım olan qədər götür
    allCachedQuestions.shuffle();
    return allCachedQuestions.take(count).toList();
  }

  // Keş təmizləməyə icazə var-yoxdur yoxla
  bool canClearCache(GameCategory category) {
    final lastClearTime = _prefs.getInt('$_lastClearPrefix${category.name}') ?? 0;
    if (lastClearTime == 0) return true;

    final hoursSinceLastClear = DateTime.now().millisecondsSinceEpoch - lastClearTime;
    const hoursInMs = _minHoursBetweenClears * 60 * 60 * 1000;

    return hoursSinceLastClear >= hoursInMs;
  }

  // Keşi təmizlə (məhdudiyyətlərlə)
  Future<bool> clearCache(GameCategory category) async {
    if (!canClearCache(category)) {
      return false; // Vaxt dolmayıb
    }

    await _prefs.remove('$_cachePrefix${category.name}');
    await _prefs.remove('$_apiCallCountPrefix${category.name}'); // API sayacını da sıfırla
    await _prefs.setInt('$_lastClearPrefix${category.name}', DateTime.now().millisecondsSinceEpoch);

    return true;
  }

  // Bütün keşi təmizlə (yalnız admin üçün - gizli kod lazım)
  Future<bool> clearAllCache(String adminCode) async {
    const correctAdminCode = "MATH_GAME_ADMIN_2024_CLEAR";
    if (adminCode != correctAdminCode) {
      return false;
    }

    for (GameCategory category in GameCategory.values) {
      await _prefs.remove('$_cachePrefix${category.name}');
      await _prefs.remove('$_apiCallCountPrefix${category.name}');
      await _prefs.remove('$_lastClearPrefix${category.name}');

      // Günlük oyun sayaclarını da təmizlə
      final today = DateTime.now();
      final todayKey = '$_dailyGameCountPrefix${category.name}_${today.year}_${today.month}_${today.day}';
      await _prefs.remove(todayKey);
    }

    return true;
  }

  // Təhlükəsizlik statistikası
  Map<String, dynamic> getSecurityStats() {
    final installDate = _prefs.getInt(_installDatePrefix) ?? DateTime.now().millisecondsSinceEpoch;
    final daysSinceInstall = (DateTime.now().millisecondsSinceEpoch - installDate) / (24 * 60 * 60 * 1000);

    // Bütün kateqoriyalar üçün ümumi API çağırışı sayını hesabla
    int totalApiCalls = 0;
    for (GameCategory category in GameCategory.values) {
      totalApiCalls += getCategoryApiCallCount(category);
    }

    final subscriptionType = getSubscriptionType();
    final userLimits = _getUserLimits();

    return {
      'deviceId': '${_deviceId.substring(0, 8)}...', // Yalnız ilk 8 simvol
      'daysSinceInstall': daysSinceInstall.round(),
      'totalApiCalls': totalApiCalls,
      'subscriptionType': subscriptionType.name,
      'maxApiCallsPerCategory': userLimits['maxApiCallsPerCategory'],
      'maxGamesPerCategoryDaily': userLimits['maxGamesPerCategoryDaily'],
    };
  }

  // Kateqoriya üçün təmizləmə məlumatı
  Map<String, dynamic> getClearInfo(GameCategory category) {
    final lastClearTime = _prefs.getInt('$_lastClearPrefix${category.name}') ?? 0;
    final canClear = canClearCache(category);

    int hoursUntilNextClear = 0;
    if (!canClear && lastClearTime > 0) {
      final timePassed = DateTime.now().millisecondsSinceEpoch - lastClearTime;
      const timeNeeded = _minHoursBetweenClears * 60 * 60 * 1000;
      hoursUntilNextClear = ((timeNeeded - timePassed) / (60 * 60 * 1000)).ceil();
    }

    return {
      'canClear': canClear,
      'hoursUntilNextClear': hoursUntilNextClear,
      'lastClearTime': lastClearTime,
    };
  }

  // Kateqoriya üçün keş statistikası
  Map<String, dynamic> getCacheStats(GameCategory category) {
    final clearInfo = getClearInfo(category);
    final apiCallCount = getCategoryApiCallCount(category);
    final subscriptionType = getSubscriptionType();
    final userLimits = _getUserLimits();
    final dailyGames = getDailyGameCount(category);

    return {
      'subscriptionType': subscriptionType.name,
      'apiCallCount': apiCallCount,
      'remainingApiCalls': math.max(0, userLimits['maxApiCallsPerCategory']! - apiCallCount),
      'canMakeApiCall': canMakeApiCall(category),
      'dailyGameCount': dailyGames,
      'remainingDailyGames': subscriptionType == SubscriptionType.free
          ? -1 // Unlimited (amma API limiti var)
          : math.max(0, userLimits['maxGamesPerCategoryDaily']! - dailyGames),
      'canPlayGame': canPlayGame(category),
      'cachedQuestionsCount': getCachedQuestions(category).length,
      'canUseCache': hasSufficientCachedQuestions(category),
      'canClearCache': clearInfo['canClear'],
      'hoursUntilNextClear': clearInfo['hoursUntilNextClear'],
      'maxApiCallsPerCategory': userLimits['maxApiCallsPerCategory'],
      'maxGamesPerCategoryDaily': userLimits['maxGamesPerCategoryDaily'],
    };
  }
}
