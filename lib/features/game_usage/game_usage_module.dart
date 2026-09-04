import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/shared_preferences_provider.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/features/user/user_module.dart';

import 'package:zifromania/features/game_usage/data/datasource/game_usage_local_datasource.dart';
import 'package:zifromania/features/game_usage/data/datasource/game_usage_local_datasource_impl.dart';
import 'package:zifromania/features/game_usage/data/datasource/question_local_datasource.dart';
import 'package:zifromania/features/game_usage/data/datasource/question_local_datasource_impl.dart';
import 'package:zifromania/features/game_usage/data/repositories/game_usage_repositories_impl.dart';
import 'package:zifromania/features/game_usage/data/repositories/question_repository_impl.dart';
import 'package:zifromania/features/game_usage/domain/entities/category_stats.dart';
import 'package:zifromania/features/game_usage/domain/repositories/question_repository.dart';
import 'package:zifromania/features/game_usage/domain/usecases/can_play_game_usecase.dart';
import 'package:zifromania/features/game_usage/domain/usecases/generate_question.dart';
import 'package:zifromania/features/game_usage/domain/usecases/get_category_stats_usecase.dart';
import 'package:zifromania/features/game_usage/domain/usecases/play_game_usecase.dart';

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

final getCategoryStatsUseCaseProvider = Provider<GetCategoryStatsUseCase>((ref) {
  return GetCategoryStatsUseCase(ref.watch(gameUsageRepositoryProvider));
});

final categoryStatsProvider = Provider.family<CategoryStats, GameCategory>((ref, category) {
  return ref.watch(getCategoryStatsUseCaseProvider).call(category);
});
