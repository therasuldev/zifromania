import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import '../domain/entities/enums.dart';
import '../domain/entities/math_question.dart';

class OpenAIService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  final String _baseUrlOpenAI = 'https://api.openai.com/v1/chat/completions';
  final String _baseUrlDeepSeekAI = 'https://api.deepseek.com/chat/completions';

  final String openAIModel = 'gpt-4o-mini';
  final String deepSeekAIModel = 'deepseek-reasoner';

  // Singleton instance
  static final OpenAIService instance = OpenAIService._internal();

  // Özəl API açarı (bura öz açarını yaz)
  final String _apiKeyOpenAI =
      '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';
  final String _apiKeyDeepSeekAI = 'sk-b42f1ca5be854ea6b8be5acba7b8a28a';
  // Private constructor
  OpenAIService._internal();

  Future<List<MathQuestion>> generateQuestions(GameDifficulty difficulty) async {
    _cancelToken = CancelToken();
    try {
      final difficultyString = _getDifficultyString(difficulty);

      final response = await _dio.post(
        _baseUrlOpenAI,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKeyOpenAI',
          },
        ),
        data: {
          "model": openAIModel,
          "response_format": {"type": "json_object"},
          "messages": [
            {
              "role": "system",
              "content": "You are a system that creates math questions with 100% accurate calculations. Your task is to generate 15 mathematically correct questions with properly distributed answers.\n\n"
                  "**OUTPUT FORMAT:** Return ONLY a JSON array with 15 question objects:\n"
                  "[\n"
                  "  {\n"
                  "    \"question\": \"6 × 2 = ?\",\n"
                  "    \"options\": {\n"
                  "      \"A\": \"12\",\n"
                  "      \"B\": \"10\",\n"
                  "      \"C\": \"14\",\n"
                  "      \"D\": \"15\"\n"
                  "    },\n"
                  "    \"correct_option\": \"A\"\n"
                  "  },\n"
                  "  ... 14 more questions ...\n"
                  "]\n\n"
                  "**MATHEMATICAL ACCURACY IS CRITICAL:**\n"
                  "1. For each question, calculate the precise mathematical answer\n"
                  "2. Place the correct answer in exactly one of the options\n"
                  "3. Double-check all calculations before finalizing\n"
                  "4. Verify that incorrect options are clearly wrong but plausible\n\n"
                  "**STRICT ANSWER DISTRIBUTION:** Across the 15 questions:\n"
                  "- Exactly 3 questions must have A as correct_option\n"
                  "- Exactly 4 questions must have B as correct_option\n"
                  "- Exactly 4 questions must have C as correct_option\n"
                  "- Exactly 4 questions must have D as correct_option\n\n"
                  "**QUESTION TYPE:** Create questions for the `$difficultyString` category:\n"
                  "- `table_battle`: Multiplication and division questions with numbers 1-12\n"
                  "- `speed`: Simple addition, subtraction, multiplication, division with 1-2 digit numbers\n"
                  "- `puzzles`: Sequence problems (find the next number, pattern recognition)\n"
                  "- `endless`: Simple operations (addition, subtraction, multiplication, division)\n"
                  "- `expert`: Complex expressions with exponents, logarithms, modulo\n"
                  "- `true_false`: For true/false, use options {\"A\": \"True\", \"B\": \"False\", \"C\": \"-\", \"D\": \"-\"}\n\n"
                  "**VALIDATION CHECKLIST - MUST COMPLETE ALL STEPS:**\n"
                  "1. Create all 15 questions with proper JSON formatting\n"
                  "2. RECALCULATE each answer independently to confirm correctness\n"
                  "3. Count distribution: exactly 3-A, 4-B, 4-C, 4-D correct answers\n"
                  "4. Verify each question has exactly one correct option\n"
                  "5. Ensure all incorrect options are clearly wrong but plausible\n\n"
                  "You must provide mathematically accurate questions where the correct_option truly contains the correct mathematical answer to the problem."
            },
            {
              "role": "user",
              "content":
                  "Generate 15 mathematically accurate questions for the `$difficultyString` category. Ensure exactly 3 questions have A as correct, 4 have B as correct, 4 have C as correct, and 4 have D as correct. Double-check all mathematical calculations before submitting."
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
        throw Exception('Gözlənilməyən JSON formatı');
      }

      log(questions.toString());

      return _convertToMathQuestions(questions, difficulty);
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        throw Exception('Request was cancelled');
      }
      log('Error generating questions: $e');
      throw Exception('Failed to generate questions: $e');
    }
  }

  String _getDifficultyString(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.speedCalculation:
        return 'speed';
      case GameDifficulty.mathPuzzles:
        return 'puzzles';
      case GameDifficulty.endless:
        return 'endless';
      case GameDifficulty.expert:
        return 'expert';
      case GameDifficulty.multiplyDivideBattle:
        return 'table_battle';
      case GameDifficulty.trueFalse:
        return 'true_false';
    }
  }

  List<MathQuestion> _convertToMathQuestions(List<dynamic> questions, GameDifficulty difficulty) {
    final List<MathQuestion> mathQuestions = [];

    for (var questionData in questions) {
      final String questionText = questionData['question'];
      final Map<String, dynamic> options = Map<String, dynamic>.from(questionData['options']);
      final String correctOptionKey = questionData['correct_option'];

      // Check if this is a true/false question
      bool isTrueFalse = difficulty == GameDifficulty.trueFalse ||
          (options.containsKey('A') && options['A'] == 'True' && options.containsKey('B') && options['B'] == 'False');

      if (isTrueFalse) {
        // For true/false questions, we'll represent the correct answer as:
        // 1 for True, 0 for False - but only internally for the correctAnswer field
        int correctAnswerValue = options[correctOptionKey] == 'True' ? 1 : 0;

        // Store the actual string options while filtering out "-" placeholder values
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
        // Handle numeric questions
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
  
  // to cancel ongoing request
  void cancel() {
    _cancelToken?.cancel('Request cancelled by user');
    _cancelToken = null;
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
