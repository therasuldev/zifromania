import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';

abstract interface class QuestionLocalDataSource {
  Future<List<MathQuestion>> getQuestions(GameCategory category);

  Future<int> getAvailableQuestionsCount(GameCategory category);
}
