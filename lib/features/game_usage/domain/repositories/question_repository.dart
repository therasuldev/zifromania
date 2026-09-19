import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/math_question.dart';

abstract interface class QuestionRepository {
  Future<List<MathQuestion>> getQuestions(GameCategory category);

  Future<int> getAvailableQuestionsCount(GameCategory category);
}
