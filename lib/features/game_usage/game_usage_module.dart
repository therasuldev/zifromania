import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/shared_preferences_provider.dart';
import 'package:zifromania/features/user/user_module.dart';

import 'data/datasource/game_usage_local_datasource.dart';
import 'data/datasource/game_usage_local_datasource_impl.dart';
import 'data/datasource/question_local_datasource.dart';
import 'data/datasource/question_local_datasource_impl.dart';
import 'data/repositories/game_usage_repositories_impl.dart';
import 'data/repositories/question_repository_impl.dart';
import 'domain/repositories/question_repository.dart';
import 'domain/usecases/can_play_game_usecase.dart';
import 'domain/usecases/generate_question.dart';
import 'domain/usecases/play_game_usecase.dart';

final gameUsageLocalDataSourceProvider = Provider<GameUsageLocalDataSource>(
  (ref) => GameUsageLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider)),
);

final gameUsageRepositoryProvider = Provider<GameUsageRepositoryImpl>(
  (ref) => GameUsageRepositoryImpl(dataSource: ref.watch(gameUsageLocalDataSourceProvider)),
);

final questionLocalDataSourceProvider = Provider<QuestionLocalDataSource>((ref) {
  return const QuestionLocalDataSourceImpl();
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepositoryImpl(localDataSource: ref.watch(questionLocalDataSourceProvider));
});

final canPlayGameUseCaseProvider = Provider<CanPlayGameUseCase>((ref) {
  return CanPlayGameUseCase(repository: ref.watch(gameUsageRepositoryProvider));
});

final playGameUseCaseProvider = Provider<PlayGameUseCase>((ref) {
  return PlayGameUseCase(repository: ref.watch(gameUsageRepositoryProvider));
});

final generateQuestionsUseCaseProvider = Provider<GenerateQuestionsUseCase>((ref) {
  return GenerateQuestionsUseCase(
    questionRepository: ref.watch(questionRepositoryProvider),
    canPlayGameUseCase: ref.watch(canPlayGameUseCaseProvider),
    playGameUseCase: ref.watch(playGameUseCaseProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});
