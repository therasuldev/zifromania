import 'dart:convert';

import 'package:dio/dio.dart';
import '../domain/entities/enums.dart';
import '../domain/entities/math_question.dart';

class OpenAIService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // Singleton instance
  static final OpenAIService instance = OpenAIService._internal();

  // Özəl API açarı (bura öz açarını yaz)
  final String _apiKey =
      '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';

  // Private constructor
  OpenAIService._internal();

  Future<List<MathQuestion>> generateQuestions(GameDifficulty difficulty) async {
    try {
      final difficultyString = _getDifficultyString(difficulty);

      // final response = await _dio.post(
      //   _baseUrl,
      //   options: Options(
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'Authorization': 'Bearer $_apiKey',
      //     },
      //   ),
      //   data: {
      //     "model": "gpt-4o-mini",
      //     "response_format": {"type": "json_object"},
      //     "messages": [
      //       {
      //         "role": "system",
      //         "content":
      //             "Sən riyaziyyat sualları yaradan bir sistemsən. Aşağıdakı qaydalara uyğun suallar yarat və yalnız JSON array formatında cavab ver:\n\n"
      //                 "1. Mövzular: toplama, çıxma, vurma, bölmə, modulu, logaritma, üstlü ədədlər, qarışıq əməliyyatlar.\n"
      //                 "2. Çətinlik kateqoriyaları və onların tələbləri:\n"
      //                 " - `easy`: 1-100 arası ədədlərlə toplama, çıxma, vurma, bölmə\n"
      //                 " - `medium`: 100-1000 arası ədədlərlə eyni əməliyyatlar\n"
      //                 " - `hard`: 1000+ ədədlərlə eyni əməliyyatlar\n"
      //                 " - `master`: logaritmik ifadələr (log₂, log₃ və s.), üstlü ifadələr (məsələn, 5^3), modulu və qarışıq (3 ədədli) əməliyyatlar\n"
      //                 " - `table`: 1-9 arası ədədlərlə vurma və bölmə sualları\n\n"
      //                 "3. Hər sual üçün:\n"
      //                 " - `question`: bir riyazi məsələ (məsələn: \"25 + 30 = ?\")\n"
      //                 " - `options`: 4 cavab variantı (A, B, C, D), biri doğru, digərləri səhv\n"
      //                 " - `correct_option`: doğru cavabın açarı (məsələn, \"C\")\n\n"
      //                 "Cavabdakı bütün field-lar ingilis dilində olmalıdır.\n"
      //                 "Cavab yalnız bu JSON massiv formatında olmalıdır:\n"
      //                 "[\n"
      //                 " {\n"
      //                 " \"question\": \"...\",\n"
      //                 " \"options\": {\n"
      //                 " \"A\": \"...\",\n"
      //                 " \"B\": \"...\",\n"
      //                 " \"C\": \"...\",\n"
      //                 " \"D\": \"...\"\n"
      //                 " },\n"
      //                 " \"correct_option\": \"...\"\n"
      //                 " },\n"
      //                 " ... (ümumilikdə 5 sual) ...\n"
      //                 "]"
      //       },
      //       {"role": "user", "content": "Mənə `$difficultyString` səviyyəsində 5 sual yarat."}
      //     ]
      //   },
      // );

      // final questionsJson = response.data['choices'][0]['message']['content'];
      final questionsJson = {
        "questions": [
          {
            "question": "25 + 30 = ?",
            "options": {"A": "50", "B": "55", "C": "60", "D": "45"},
            "correct_option": "B"
          },
          {
            "question": "72 - 14 = ?",
            "options": {"A": "58", "B": "60", "C": "62", "D": "64"},
            "correct_option": "A"
          },
          {
            "question": "8 * 9 = ?",
            "options": {"A": "64", "B": "72", "C": "81", "D": "74"},
            "correct_option": "B"
          },
          {
            "question": "56 / 7 = ?",
            "options": {"A": "6", "B": "7", "C": "8", "D": "9"},
            "correct_option": "C"
          },
          {
            "question": "15 + 20 = ?",
            "options": {"A": "30", "B": "35", "C": "25", "D": "40"},
            "correct_option": "B"
          }
        ]
      };

      final questionString = json.encode(questionsJson);
      final List<dynamic> questions = _parseQuestionsJson(questionString);

      return _convertToMathQuestions(questions, difficulty);
    } catch (e) {
      print('Error generating questions: $e');
      throw Exception('Failed to generate questions: $e');
    }
  }

  List<dynamic> _parseQuestionsJson(String jsonString) {
    try {
      final decoded = json.decode(jsonString);

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('questions')) {
          return decoded['questions'];
        }
      }

      if (decoded is List) {
        return decoded;
      }

      throw Exception('Gözlənilməyən JSON formatı');
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse questions JSON: $e');
    }
  }

  List<MathQuestion> _convertToMathQuestions(List<dynamic> questions, GameDifficulty difficulty) {
    final List<MathQuestion> mathQuestions = [];

    for (var questionData in questions) {
      final String questionText = questionData['question'];
      final Map<String, dynamic> options = questionData['options'];
      final String correctOptionKey = questionData['correct_option'];

      final int correctAnswerValue = int.parse(options[correctOptionKey].toString());

      final List<int> answerOptions = [];
      options.forEach((key, value) {
        answerOptions.add(int.parse(value.toString()));
      });

      final OperationType operationType = _determineOperationType(questionText);

      mathQuestions.add(MathQuestion(
        question: questionText,
        correctAnswer: correctAnswerValue,
        answerOptions: answerOptions,
        operation: operationType,
      ));
    }

    return mathQuestions;
  }

  String _getDifficultyString(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.medium:
        return 'medium';
      case GameDifficulty.hard:
        return 'hard';
      case GameDifficulty.master:
        return 'master';
      case GameDifficulty.timesDivideTable:
        return 'table';
      default:
        return 'easy';
    }
  }

  OperationType _determineOperationType(String question) {
    if (question.contains('+')) return OperationType.addition;
    if (question.contains('-')) return OperationType.subtraction;
    if (question.contains('×') || question.contains('*')) return OperationType.multiplication;
    if (question.contains('÷') || question.contains('/')) return OperationType.division;
    if (question.contains('%')) return OperationType.modulo;
    if (question.contains('^')) return OperationType.exponentiation;
    if (question.contains('log')) return OperationType.logarithm;
    return OperationType.addition;
  }
}
