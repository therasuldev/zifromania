import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:zifromania/app_exception.dart';
import 'package:zifromania/domain/entities/global.dart';
import 'package:zifromania/presentation/state-managment/game/game_bloc.dart';
import '../domain/entities/enums.dart';
import '../domain/entities/math_question.dart';
import 'game_limit_service.dart';

class QuestionService {
  QuestionService({required GameLimitService gameLimitService}) : _gameLimitService = gameLimitService;

  final GameLimitService _gameLimitService;

  Future<List<MathQuestion>> generateQuestions(
    GameCategory gameCategory, {
    int questionCount = 15,
    CancelToken? cancelToken,
  }) async {
    // Cancel token yoxla
    if (cancelToken?.isCancelled == true) {
      throw Exception('Operation cancelled');
    }

    // Günlük limit yoxlaması
    if (!_gameLimitService.canPlayGame(gameCategory)) {
      final stats = _gameLimitService.getCategoryStats(gameCategory);
      throw AppException(
        AppErrorType.dailyLimitReached,
        'Daily limit reached for ${gameCategory.name} (${stats['dailyRequestCount']}/${stats['categoryLimit']} requests used). Flexible games: ${stats['flexibleGamesAvailable']}',
      );
    }

    // File-dan sualları oxu
    log.i('Loading questions from file for ${gameCategory.name}');
    final allQuestions = await _loadQuestionsFromFile(gameCategory);

    // 7 saniyəlik gözləmə, amma cancel token yoxlayaraq
    for (int i = 0; i < 70; i++) {
      // 70 * 100ms = 7 saniyə
      if (cancelToken?.isCancelled == true) {
        log.i('Question generation cancelled for ${gameCategory.name}');
        throw Exception('Operation cancelled');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Yenə cancel yoxla
    if (cancelToken?.isCancelled == true) {
      throw Exception('Operation cancelled');
    }

    // *** YENİ LOQIKA: playGame metodu istifadə et ***
    // Bu metod həm normal limit artırır, həm də lazım olduqda flexible game istifadə edir
    await _gameLimitService.playGame(gameCategory);

    // Sualları qarışdır və tələb olunan sayda qaytır
    allQuestions.shuffle();
    final selectedQuestions = allQuestions.take(questionCount).toList();

    log.i('Generated ${selectedQuestions.length} questions for ${gameCategory.name}');
    return selectedQuestions;
  }

  Future<List<MathQuestion>> _loadQuestionsFromFile(GameCategory gameCategory) async {
    try {
      final categoryString = _getCategoryString(gameCategory);
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<dynamic> questions;
      if (jsonData.containsKey('questions')) {
        questions = jsonData['questions'];
      } else {
        throw AppException(
          AppErrorType.invalidJson,
          'Invalid JSON format: missing "questions" key',
        );
      }

      return _convertToMathQuestions(questions, gameCategory);
    } catch (e) {
      log.e('Error loading questions from file: $e');
      throw AppException(
        AppErrorType.fileLoadError,
        'Failed to load questions from file: $e',
      );
    }
  }

  List<MathQuestion> _convertToMathQuestions(List<dynamic> questions, GameCategory gameCategory) {
    final List<MathQuestion> mathQuestions = [];

    for (var questionData in questions) {
      try {
        final String questionText = questionData['question'];
        final Map<String, dynamic> options = Map<String, dynamic>.from(questionData['options']);
        final String correctOptionKey = questionData['correct_option'];

        bool isTrueFalse = gameCategory == GameCategory.trueOrFalse ||
            (options.containsKey('A') && options['A'] == 'True' && options.containsKey('B') && options['B'] == 'False');

        if (isTrueFalse) {
          // True/False sualları üçün
          int correctAnswerValue = options[correctOptionKey] == 'True' ? 1 : 0;
          Map<String, String> answerOptions = {};

          options.forEach((key, value) {
            if (value != '-' && value != null) {
              answerOptions[key] = value.toString();
            }
          });

          mathQuestions.add(MathQuestion(
            question: questionText,
            correctAnswer: correctAnswerValue,
            answerOptions: answerOptions,
          ));
        } else {
          // Rəqəmli suallar üçün
          int? correctAnswerValue;
          try {
            correctAnswerValue = int.tryParse(options[correctOptionKey]?.toString() ?? '0');
          } catch (e) {
            log.w('Error parsing correct answer: $e for question: $questionText');
            correctAnswerValue = 0;
          }

          Map<String, String> answerOptions = {};
          options.forEach((key, value) {
            if (value != null) {
              answerOptions[key] = value.toString();
            }
          });

          mathQuestions.add(MathQuestion(
            question: questionText,
            correctAnswer: correctAnswerValue ?? 0,
            answerOptions: answerOptions,
          ));
        }
      } catch (e) {
        log.w('Error processing question: $e, skipping...');
        continue;
      }
    }

    return mathQuestions;
  }

  String _getCategoryString(GameCategory gameCategory) {
    return switch (gameCategory) {
      GameCategory.quickThinking => 'quick_thinking',
      GameCategory.training => 'training',
      GameCategory.expert => 'expert',
      GameCategory.multiplyDivide => 'multiply_divide',
      GameCategory.trueOrFalse => 'true_or_false',
    };
  }

  // Kateqoriya üçün mövcud sualların sayını yoxla
  Future<int> getAvailableQuestionsCount(GameCategory gameCategory) async {
    try {
      final categoryString = _getCategoryString(gameCategory);
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData.containsKey('questions')) {
        return (jsonData['questions'] as List).length;
      }
      return 0;
    } catch (e) {
      log.e('Error getting available questions count: $e');
      return 0;
    }
  }

  // Limit statistikasını göstər
  Map<String, dynamic> getLimitStatistics() {
    return _gameLimitService.getAllCategoriesStats();
  }

  // Kateqoriya üçün limit statistikası
  Map<String, dynamic> getCategoryLimitStats(GameCategory category) {
    return _gameLimitService.getCategoryStats(category);
  }

  // Admin paneli üçün günlük sayacları təmizlə
  Future<bool> adminClearDailyCounters(String adminCode) async {
    return await _gameLimitService.clearDailyCounters(adminCode);
  }

  // Bütün kateqoriyalar üçün məlumat (YENİ LOQIKA ilə)
  Future<Map<String, dynamic>> getAllCategoriesInfo() async {
    Map<String, dynamic> info = {};

    for (GameCategory category in GameCategory.values) {
      final availableQuestions = await getAvailableQuestionsCount(category);
      final categoryStats = _gameLimitService.getCategoryStats(category);

      info[category.name] = {
        'availableInFile': availableQuestions,
        'dailyRequests': categoryStats['dailyRequestCount'],
        'categoryLimit': categoryStats['categoryLimit'],
        'remainingNormalGames': categoryStats['remainingNormalGames'],
        'flexibleGamesAvailable': categoryStats['flexibleGamesAvailable'],
        'totalAvailableGames': categoryStats['totalAvailableGames'],
        'canPlay': categoryStats['canPlayGame'],
      };
    }

    return info;
  }

  // Təhlükəsizlik statistikası
  Map<String, dynamic> getSecurityStats() {
    return _gameLimitService.getSecurityStats();
  }

  // Abunəlik tipini dəyişdir
  Future<void> setSubscriptionType(SubscriptionType subscriptionType) async {
    await _gameLimitService.setSubscriptionType(subscriptionType);
  }

  // Abunəlik tipini al
  SubscriptionType getSubscriptionType() {
    return _gameLimitService.getSubscriptionType();
  }

  // *** YENİ METODLAR: Reklam və Flexible Games idarəetməsi ***

  // Reklam izləyə bilər-yoxdur yoxla
  bool canWatchAdForReward() {
    return _gameLimitService.canWatchAdForReward();
  }

  // Reklam izlədikdən sonra çağır
  Future<void> watchedAdForReward() async {
    await _gameLimitService.incrementGlobalAdWatchedCount();
  }

  // Ümumi reklam vəziyyətini al
  Map<String, dynamic> getGlobalAdStatus() {
    return _gameLimitService.getGlobalAdStatus();
  }

  // Flexible games sayını al
  int getFlexibleGamesCount() {
    return _gameLimitService.getFlexibleGamesCount();
  }

  // Kateqoriya üçün stream al (UI üçün real-time yenilənmə)
  Stream<Map<String, int>> getCategoryLimitStream(GameCategory category) {
    return _gameLimitService.getCategoryLimitStream(category);
  }
}
