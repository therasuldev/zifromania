import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/math_question.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/game_usage/data/datasource/question_local_datasource.dart';

final class QuestionLocalDataSourceImpl implements QuestionLocalDataSource {
  const QuestionLocalDataSourceImpl();

  @override
  Future<List<MathQuestion>> getQuestions(GameCategory category) async {
    try {
      final categoryString = category.toTextWithUnderscores();
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      if (!jsonData.containsKey('questions')) {
        throw const InvalidJsonException(
          message: 'Invalid JSON format: missing "questions" key',
        );
      }

      final questionsJson = jsonData['questions'] as List<dynamic>;
      return _convertToMathQuestions(questionsJson, category);
    } catch (e) {
      throw InvalidJsonException(
        message: 'Failed to load or parse questions JSON',
        error: e,
      );
    }
  }

  @override
  Future<int> getAvailableQuestionsCount(GameCategory category) async {
    try {
      final categoryString = category.toTextWithUnderscores();
      final jsonString = await rootBundle.loadString('assets/questions/$categoryString.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

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
        final questionText = questionData['question'] as String;
        final options = Map<String, dynamic>.from(questionData['options'] as Map<String, dynamic>);
        final correctOptionKey = questionData['correct_option'];

        final optionValues = options.values.map((value) => value.toString()).toSet();
        final isTrueFalse = gameCategory == GameCategory.trueOrFalse ||
            (optionValues.contains('True') && optionValues.contains('False'));

        if (isTrueFalse) {
          final correctAnswerValue = options[correctOptionKey] == 'True' ? 1 : 0;
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
