import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/math_question.dart';
import 'package:zifromania/features/game_usage/data/datasource/question_local_datasource.dart';
import 'package:zifromania/features/game_usage/domain/repositories/question_repository.dart';

final class QuestionRepositoryImpl implements QuestionRepository {
  const QuestionRepositoryImpl({required this.localDataSource});

  final QuestionLocalDataSource localDataSource;

  @override
  Future<List<MathQuestion>> getQuestions(GameCategory category) {
    return localDataSource.getQuestions(category);
  }

  @override
  Future<int> getAvailableQuestionsCount(GameCategory category) {
    return localDataSource.getAvailableQuestionsCount(category);
  }
}
