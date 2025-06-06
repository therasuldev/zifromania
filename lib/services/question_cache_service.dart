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
  static const String _apiCallCountPrefix = 'api_call_count_'; // Hər kateqoriya üçün API çağırışı sayacı
  static const String _lastClearPrefix = 'last_clear_';
  static const String _deviceIdPrefix = 'device_id_';
  static const String _installDatePrefix = 'install_date_';

  static const int _maxApiCallsPerCategory = 4; // Hər kateqoriya üçün maksimum 4 API çağırışı
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

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  // Kateqoriya üçün API çağırışı limitini yoxla
  bool canMakeApiCall(GameCategory category) {
    final apiCallCount = getCategoryApiCallCount(category);
    return apiCallCount < _maxApiCallsPerCategory;
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
                answerOptions: List<dynamic>.from(q['answerOptions']),
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

    return {
      'deviceId': '${_deviceId.substring(0, 8)}...', // Yalnız ilk 8 simvol
      'daysSinceInstall': daysSinceInstall.round(),
      'totalApiCalls': totalApiCalls,
      'maxApiCallsPerCategory': _maxApiCallsPerCategory,
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

    return {
      'apiCallCount': apiCallCount,
      'remainingApiCalls': math.max(0, _maxApiCallsPerCategory - apiCallCount),
      'canMakeApiCall': canMakeApiCall(category),
      'cachedQuestionsCount': getCachedQuestions(category).length,
      'canUseCache': hasSufficientCachedQuestions(category),
      'canClearCache': clearInfo['canClear'],
      'hoursUntilNextClear': clearInfo['hoursUntilNextClear'],
    };
  }
}
