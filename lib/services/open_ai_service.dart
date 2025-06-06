import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zifromania/domain/entities/global.dart';
import '../domain/entities/enums.dart';
import '../domain/entities/math_question.dart';
import 'question_cache_service.dart';

class EnhancedOpenAIService {
  EnhancedOpenAIService({required QuestionCacheService cacheService}) : _cacheService = cacheService;

  final Dio _dio = Dio();
  final QuestionCacheService _cacheService;
  CancelToken? _cancelToken;
  final String _baseUrlOpenAI = 'https://api.openai.com/v1/chat/completions';
  // final String _baseUrlDeepSeekAI = 'https://api.deepseek.com/chat/completions';

  final String openAIModel = 'gpt-4o-mini';
  final String deepSeekAIModel = 'deepseek-reasoner';

  // Özəl API açarı (bura öz açarını yaz)
  final String _apiKeyOpenAI =
      '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';
  // final String _apiKeyDeepSeekAI = 'sk-b42f1ca5be854ea6b8be5acba7b8a28a';

  Future<List<MathQuestion>> generateQuestions(GameCategory gameCategory, {int questionCount = 5}) async {
    // Kateqoriya üçün API limit yoxlaması
    if (!_cacheService.canMakeApiCall(gameCategory)) {
      // API limiti bitibsə, keştən sualları gətir
      if (_cacheService.hasSufficientCachedQuestions(gameCategory)) {
        log.i('API limit reached for ${gameCategory.name}. Using cached questions.');
        final questions = _cacheService.getShuffledQuestionsFromCache(gameCategory, questionCount);
        return questions;
      } else {
        // Həm API limiti bitib, həm də keşdə kifayət qədər sual yoxdur
        final stats = _cacheService.getCacheStats(gameCategory);
        throw Exception(
            'API limit reached for ${gameCategory.name} (${stats['apiCallCount']}/4 calls used) and insufficient cached questions (${stats['cachedQuestionsCount']} available, need $questionCount).');
      }
    }

    // API istifadə edə bilərik
    log.i('Generating questions from API for ${gameCategory.name}');

    final questions = await _generateFromAPI(gameCategory, questionCount, aiModel: openAIModel);

    // ✅ API çağırıldıqdan sonra kateqoriya üçün sayacı artır
    await _cacheService.incrementCategoryApiCallCount(gameCategory);

    // Sualları keşə əlavə et
    await _cacheService.addQuestionsToCache(gameCategory, questions);

    log.i('API call count for ${gameCategory.name}: ${_cacheService.getCategoryApiCallCount(gameCategory)}/4');

    return questions;
  }

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
    // Daha təfərrüatlı sistem prompt-u
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

  String _getCategoryString(GameCategory gameCategory) {
    return switch (gameCategory) {
      GameCategory.quickThinking => 'quick_thinking',
      GameCategory.training => 'training',
      GameCategory.expert => 'expert',
      GameCategory.multiplyDivide => 'multiply_divide',
      GameCategory.trueOrFalse => 'true_or_false',
    };
  }

  List<MathQuestion> _convertToMathQuestions(List<dynamic> questions, GameCategory gameCategory) {
    final List<MathQuestion> mathQuestions = [];

    for (var questionData in questions) {
      final String questionText = questionData['question'];
      final Map<String, dynamic> options = Map<String, dynamic>.from(questionData['options']);
      final String correctOptionKey = questionData['correct_option'];

      bool isTrueFalse = gameCategory == GameCategory.trueOrFalse ||
          (options.containsKey('A') && options['A'] == 'True' && options.containsKey('B') && options['B'] == 'False');

      if (isTrueFalse) {
        int correctAnswerValue = options[correctOptionKey] == 'True' ? 1 : 0;
        List<dynamic> answerOptions = [];
        options.forEach((key, value) {
          if (value != '-') {
            answerOptions.add(value);
          }
        });

        mathQuestions.add(MathQuestion(
          question: questionText,
          correctAnswer: correctAnswerValue,
          answerOptions: answerOptions,
        ));
      } else {
        int? correctAnswerValue;
        try {
          correctAnswerValue = int.tryParse(options[correctOptionKey]?.toString() ?? '0');
        } catch (e) {
          print('Error parsing correct answer: $e for question: $questionText');
          correctAnswerValue = 0;
        }

        final List<dynamic> answerOptions = [];
        options.forEach((key, value) {
          final parsed = int.tryParse(value.toString());
          if (parsed != null) {
            answerOptions.add(parsed);
          }
        });

        mathQuestions.add(MathQuestion(
          question: questionText,
          correctAnswer: correctAnswerValue ?? 0,
          answerOptions: answerOptions,
        ));
      }
    }

    return mathQuestions;
  }

  void cancel() {
    _cancelToken?.cancel('Request cancelled by user');
    _cancelToken = null;
  }

// Kəş statistikasını göstər
  Map<String, dynamic> getCacheStatistics() {
    Map<String, dynamic> stats = {
      'security': _cacheService.getSecurityStats(),
      'categories': {},
    };

    for (GameCategory category in GameCategory.values) {
      stats['categories'][category.name] = _cacheService.getCacheStats(category);
    }

    return stats;
  }

  // Admin paneli üçün kəş təmizləmə
  Future<bool> adminClearCache(String adminCode, {GameCategory? category}) async {
    if (category != null) {
      return await _cacheService.clearCache(category);
    } else {
      return await _cacheService.clearAllCache(adminCode);
    }
  }
}

// final questionsJson = {
//         "questions": [
//           {
//             "question": "25 + 30 = ?",
//             "options": {"A": "50", "B": "55", "C": "60", "D": "45"},
//             "correct_option": "B"
//           },
//           {
//             "question": "72 - 14 = ?",
//             "options": {"A": "58", "B": "60", "C": "62", "D": "64"},
//             "correct_option": "A"
//           },
//           {
//             "question": "8 * 9 = ?",
//             "options": {"A": "64", "B": "72", "C": "81", "D": "74"},
//             "correct_option": "B"
//           },
//           {
//             "question": "56 / 7 = ?",
//             "options": {"A": "6", "B": "7", "C": "8", "D": "9"},
//             "correct_option": "C"
//           },
//           {
//             "question": "15 + 20 = ?",
//             "options": {"A": "30", "B": "35", "C": "25", "D": "40"},
//             "correct_option": "B"
//           }
//         ]
//       };
