import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:zifromania/app_exception.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'question_local_datasource.dart';

final class QuestionLocalDataSourceImpl implements QuestionLocalDataSource {
  const QuestionLocalDataSourceImpl();

  @override
  Future<List<MathQuestion>> getQuestions(GameCategory category) async {
    try {
      final categoryString = category.toTextWithUnderscores();
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (!jsonData.containsKey('questions')) {
        throw const AppException(
          AppErrorType.invalidJson,
          'Invalid JSON format: missing "questions" key',
        );
      }

      final List<dynamic> questionsJson = jsonData['questions'];
      return _convertToMathQuestions(questionsJson, category);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        AppErrorType.fileLoadError,
        'Failed to load questions from file: $e',
      );
    }
  }

  @override
  Future<int> getAvailableQuestionsCount(GameCategory category) async {
    try {
      final categoryString = category.toTextWithUnderscores();
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData.containsKey('questions')) {
        return (jsonData['questions'] as List).length;
      }
      return 0;
    } catch (e) {
      return 0;
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
            (options.containsKey('A') && options['A'] == tr('title.true') && options.containsKey('B') && options['B'] == tr('title.false'));

        if (isTrueFalse) {
          int correctAnswerValue = options[correctOptionKey] == tr('title.true') ? 1 : 0;
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
          int? correctAnswerValue = int.tryParse(options[correctOptionKey]?.toString() ?? '0');
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
      } catch (_) {
        continue;
      }
    }

    return mathQuestions;
  }
}
