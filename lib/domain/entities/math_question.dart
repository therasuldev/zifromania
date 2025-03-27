import 'enums.dart';

class MathQuestion {
  final String question;
  final int correctAnswer;
  final List<int> answerOptions;
  final OperationType operation;

  const MathQuestion({
    required this.question,
    required this.correctAnswer,
    required this.answerOptions,
    required this.operation,
  });
}
