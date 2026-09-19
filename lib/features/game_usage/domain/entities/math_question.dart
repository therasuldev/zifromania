import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';

class MathQuestion {
  final String question;
  final int correctAnswer;
  final Map<String, String> answerOptions;

  const MathQuestion({
    required this.question,
    required this.correctAnswer,
    required this.answerOptions,
  });

  factory MathQuestion.fromJson(Map<String, dynamic> json, GameCategory gameCategory) {
    final String questionText = json['question'] as String;
    final Map<String, dynamic> rawOptions = Map<String, dynamic>.from(json['options'] as Map<String, dynamic>);
    final String correctOptionKey = json['correct_option']?.toString() ?? '';

    final optionValues = rawOptions.values.map((value) => value.toString()).toSet();
    final isTrueFalse = gameCategory == GameCategory.trueOrFalse ||
        (optionValues.contains('True') && optionValues.contains('False'));

    if (isTrueFalse) {
      final correctAnswerValue = rawOptions[correctOptionKey] == 'True' ? 1 : 0;
      Map<String, String> answerOptions = {};

      rawOptions.forEach((key, value) {
        if (value != null && value != '-') {
          answerOptions[key] = value.toString();
        }
      });

      return MathQuestion(
        question: questionText,
        correctAnswer: correctAnswerValue,
        answerOptions: answerOptions,
      );
    } else {
      int correctAnswerValue = int.tryParse(rawOptions[correctOptionKey]?.toString() ?? '0') ?? 0;
      Map<String, String> answerOptions = {};

      rawOptions.forEach((key, value) {
        if (value != null) {
          answerOptions[key] = value.toString();
        }
      });

      return MathQuestion(
        question: questionText,
        correctAnswer: correctAnswerValue,
        answerOptions: answerOptions,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'correct_option': correctAnswer,
        'options': answerOptions,
      };
}
