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
        'Daily limit reached for ${gameCategory.name} (${stats['dailyRequestCount']}/${stats['dailyLimit']} requests used).',
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

    // Günlük request sayını artır
    await _gameLimitService.incrementDailyRequestCount(gameCategory);

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

  // Bütün kateqoriyalar üçün məlumat
  Future<Map<String, dynamic>> getAllCategoriesInfo() async {
    Map<String, dynamic> info = {};

    for (GameCategory category in GameCategory.values) {
      final availableQuestions = await getAvailableQuestionsCount(category);
      final categoryStats = _gameLimitService.getCategoryStats(category);

      info[category.name] = {
        'availableInFile': availableQuestions,
        'dailyRequests': categoryStats['dailyRequestCount'],
        'remainingRequests': categoryStats['remainingDailyRequests'],
        'canPlay': categoryStats['canPlayGame'],
        'dailyLimit': categoryStats['dailyLimit'],
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
}

/* 
=== API İlə Bağlı Kod (Komment edildi) ===

import 'package:dio/dio.dart';

class EnhancedOpenAIService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  final String _baseUrlOpenAI = 'https://api.openai.com/v1/chat/completions';
  // final String _baseUrlDeepSeekAI = 'https://api.deepseek.com/chat/completions';

  final String openAIModel = 'gpt-4o-mini';
  final String deepSeekAIModel = 'deepseek-reasoner';

  // Özəl API açarı (bura öz açarını yaz)
  final String _apiKeyOpenAI =
      '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';
  // final String _apiKeyDeepSeekAI = 'sk-b42f1ca5be854ea6b8be5acba7b8a28a';

  Future<List<MathQuestion>> _generateFromAPI(GameCategory gameCategory, int questionCount, {required String aiModel}) async {
    _cancelToken = CancelToken();

    try {
      final categoryString = _getCategoryString(gameCategory);
      log.i('Using model: $aiModel for ${gameCategory.name}');

      final response = await _dio.post(
        _baseUrlOpenAI,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKeyOpenAI',
          },
        ),
        data: {
          "model": aiModel,
          "response_format": {"type": "json_object"},
          "messages": [
            {"role": "system", "content": _getSystemPrompt(categoryString, questionCount)},
            {
              "role": "user",
              "content":
                  "Generate $questionCount mathematically accurate questions for the `$categoryString` category. Ensure proper answer distribution and double-check all calculations."
            }
          ]
        },
        cancelToken: _cancelToken,
      );

      final rawContent = response.data['choices'][0]['message']['content'];
      final dynamic decodedJson = json.decode(rawContent);

      List<dynamic> questions;
      if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('questions')) {
        questions = decodedJson['questions'];
      } else if (decodedJson is List) {
        questions = decodedJson;
      } else {
        throw Exception('Unexpected JSON format');
      }

      return _convertToMathQuestions(questions, gameCategory);
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        throw Exception('Request was cancelled');
      }
      log.e('Error generating questions: $e');
      throw Exception('Failed to generate questions: $e');
    }
  }

  String _getSystemPrompt(String categoryString, int questionCount) {
    return """You are a system that creates math questions with 100% accurate calculations. Your task is to generate $questionCount mathematically correct questions with properly distributed answers.

**OUTPUT FORMAT:** Return ONLY a JSON array with $questionCount question objects:
[
  {
    "question": "6 × 2 = ?",
    "options": {
      "A": "12",
      "B": "10", 
      "C": "14",
      "D": "15"
    },
    "correct_option": "A"
  },
  ... ${questionCount - 1} more questions ...
]

**MATHEMATICAL ACCURACY IS CRITICAL:**
1. For each question, calculate the precise mathematical answer
2. Place the correct answer in exactly one of the options
3. Double-check all calculations before finalizing
4. Verify that incorrect options are clearly wrong but plausible

**QUESTION TYPE:** Create questions for the `$categoryString` category:
- `quick_thinking`: Simple addition, subtraction, multiplication, division with 1-2 digit numbers
- `training`: Basic arithmetic operations, good for practice
- `expert`: Complex expressions with exponents, logarithms, advanced operations
- `multiply_divide`: Multiplication and division questions
- `true_or_false`: For true/false, use options {"A": "True", "B": "False", "C": "-", "D": "-"}

**VALIDATION CHECKLIST:**
1. Create all $questionCount questions with proper JSON formatting
2. RECALCULATE each answer independently to confirm correctness
3. Verify each question has exactly one correct option
4. Ensure all incorrect options are clearly wrong but plausible

You must provide mathematically accurate questions where the correct_option truly contains the correct mathematical answer to the problem.""";
  }

  void cancel() {
    _cancelToken?.cancel('Request cancelled by user');
    _cancelToken = null;
  }
}

// final questionsJson = {
//   "questions": [
//     {
//       "question": "25 + 30 = ?",
//       "options": {"A": "50", "B": "55", "C": "60", "D": "45"},
//       "correct_option": "B"
//     },
//     {
//       "question": "72 - 14 = ?",
//       "options": {"A": "58", "B": "60", "C": "62", "D": "64"},
//       "correct_option": "A"
//     },
//     {
//       "question": "8 * 9 = ?",
//       "options": {"A": "64", "B": "72", "C": "81", "D": "74"},
//       "correct_option": "B"
//     },
//     {
//       "question": "56 / 7 = ?",
//       "options": {"A": "6", "B": "7", "C": "8", "D": "9"},
//       "correct_option": "C"
//     },
//     {
//       "question": "15 + 20 = ?",
//       "options": {"A": "30", "B": "35", "C": "25", "D": "40"},
//       "correct_option": "B"
//     }
//   ]
// };

*/
