// lib/data/cache/question_cache_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/math_question.dart';

class QuestionCacheService {
  static const String _cachePrefix = 'cached_questions_';
  static const String _playCountPrefix = 'play_count_';
  static const String _lastClearPrefix = 'last_clear_';
  static const String _totalApiCallsPrefix = 'total_api_calls_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';

  static const int _maxPlaysBeforeCache = 4; // 4 oyundan sonra kəşə keç
  static const int _questionsPerGame = 50; // Hər oyunda 50 sual
  static const int _maxApiCallsPerDay = 10; // Gündə maksimum 10 API çağırışı
  static const int _minHoursBetweenClears = 24; // Kəş silmə arası minimum 24 saat
  static const int _maxTotalApiCalls = 50; // Ümumi maksimum API çağırışı

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

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // API çağırışı limitini yoxla
  bool canMakeApiCall(GameCategory category) {
    // Ümumi API çağırışı limiti
    final totalApiCalls = getTotalApiCalls();
    if (totalApiCalls >= _maxTotalApiCalls) {
      return false;
    }

    // Günlük limit yoxla
    final todayApiCalls = getTodayApiCalls();
    if (todayApiCalls >= _maxApiCallsPerDay) {
      return false;
    }

    // Kəş təmizləmə arası vaxt yoxla
    if (!canClearCache(category)) {
      return hasSufficientCachedQuestions(category) ? false : true;
    }

    return true;
  }

  // Bugünkü API çağırışları
  int getTodayApiCalls() {
    final today = DateTime.now();
    final todayKey = 'api_calls_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(todayKey) ?? 0;
  }

  // Bugünkü API çağırışını artır
  Future<void> incrementTodayApiCalls() async {
    final today = DateTime.now();
    final todayKey = 'api_calls_${today.year}_${today.month}_${today.day}';
    final currentCount = getTodayApiCalls();
    await _prefs.setInt(todayKey, currentCount + 1);

    // Ümumi sayacı da artır
    final totalCalls = getTotalApiCalls();
    await _prefs.setInt(_totalApiCallsPrefix, totalCalls + 1);
  }

  // Ümumi API çağırışları
  int getTotalApiCalls() {
    return _prefs.getInt(_totalApiCallsPrefix) ?? 0;
  }

  // Kateqoriya üçün oyun sayını al
  int getPlayCount(GameCategory category) {
    return _prefs.getInt('$_playCountPrefix${category.name}') ?? 0;
  }

  // Oyun sayını artır
  Future<void> incrementPlayCount(GameCategory category) async {
    final currentCount = getPlayCount(category);
    await _prefs.setInt('$_playCountPrefix${category.name}', currentCount + 1);
  }

  // Kateqoriya üçün kəşdə kifayət qədər sual var-yoxdur yoxla
  bool hasSufficientCachedQuestions(GameCategory category) {
    final playCount = getPlayCount(category);
    if (playCount < _maxPlaysBeforeCache) return false;

    final cachedQuestions = getCachedQuestions(category);
    return cachedQuestions.length >= _questionsPerGame;
  }

  // API-dən alınan sualları kəşə əlavə et
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

  // Kəşdən sualları al
  List<MathQuestion> getCachedQuestions(GameCategory category) {
    final cachedData = _prefs.getString('$_cachePrefix${category.name}');
    if (cachedData == null) return [];

    try {
      final List<dynamic> questionsJson = json.decode(cachedData);
      return questionsJson
          .map((q) => MathQuestion(
                question: q['question'],
                correctAnswer: q['correctAnswer'],
                answerOptions: List<dynamic>.from(q['answerOptions']),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Kəşdən qarışdırılmış suallar al
  List<MathQuestion> getShuffledQuestionsFromCache(GameCategory category, int count) {
    final allCachedQuestions = getCachedQuestions(category);
    if (allCachedQuestions.length < count) {
      return allCachedQuestions..shuffle();
    }

    // Qarışdır və lazım olan qədər götür
    allCachedQuestions.shuffle();
    return allCachedQuestions.take(count).toList();
  }

  // Kəş təmizləməyə icazə var-yoxdur yoxla
  bool canClearCache(GameCategory category) {
    final lastClearTime = _prefs.getInt('$_lastClearPrefix${category.name}') ?? 0;
    if (lastClearTime == 0) return true;

    final hoursSinceLastClear = DateTime.now().millisecondsSinceEpoch - lastClearTime;
    const hoursInMs = _minHoursBetweenClears * 60 * 60 * 1000;

    return hoursSinceLastClear >= hoursInMs;
  }

  // Kəşi təmizlə (məhdudiyyətlərlə)
  Future<bool> clearCache(GameCategory category) async {
    if (!canClearCache(category)) {
      return false; // Vaxt dolmayıb
    }

    final totalApiCalls = getTotalApiCalls();
    if (totalApiCalls >= _maxTotalApiCalls) {
      return false; // API limit dolub
    }

    await _prefs.remove('$_cachePrefix${category.name}');
    await _prefs.remove('$_playCountPrefix${category.name}');
    await _prefs.setInt('$_lastClearPrefix${category.name}', DateTime.now().millisecondsSinceEpoch);

    return true;
  }

  // Bütün kəşi təmizlə (yalnız admin üçün - gizli kod lazım)
  Future<bool> clearAllCache(String adminCode) async {
    const correctAdminCode = "MATH_GAME_ADMIN_2024_CLEAR";
    if (adminCode != correctAdminCode) {
      return false;
    }

    for (GameCategory category in GameCategory.values) {
      await _prefs.remove('$_cachePrefix${category.name}');
      await _prefs.remove('$_playCountPrefix${category.name}');
      await _prefs.remove('$_lastClearPrefix${category.name}');
    }

    // API sayaclarını sıfırla
    await _prefs.remove(_totalApiCallsPrefix);
    return true;
  }

  // Təhlükəsizlik statistikası
  Map<String, dynamic> getSecurityStats() {
    final installDate = _prefs.getInt(_installDatePrefix) ?? DateTime.now().millisecondsSinceEpoch;
    final daysSinceInstall = (DateTime.now().millisecondsSinceEpoch - installDate) / (24 * 60 * 60 * 1000);

    return {
      'deviceId': '${_deviceId.substring(0, 8)}...', // Yalnız ilk 8 simvol
      'daysSinceInstall': daysSinceInstall.round(),
      'totalApiCalls': getTotalApiCalls(),
      'todayApiCalls': getTodayApiCalls(),
      'remainingTodayApiCalls': math.max(0, _maxApiCallsPerDay - getTodayApiCalls()),
      'remainingTotalApiCalls': math.max(0, _maxTotalApiCalls - getTotalApiCalls()),
      'canMakeApiCall': getTotalApiCalls() < _maxTotalApiCalls && getTodayApiCalls() < _maxApiCallsPerDay,
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

  // Kateqoriya üçün kəş statistikası
  Map<String, dynamic> getCacheStats(GameCategory category) {
    final clearInfo = getClearInfo(category);

    return {
      'playCount': getPlayCount(category),
      'cachedQuestionsCount': getCachedQuestions(category).length,
      'canUseCache': hasSufficientCachedQuestions(category),
      'remainingPlaysForCache': math.max(0, _maxPlaysBeforeCache - getPlayCount(category)),
      'canClearCache': clearInfo['canClear'],
      'hoursUntilNextClear': clearInfo['hoursUntilNextClear'],
    };
  }
}
