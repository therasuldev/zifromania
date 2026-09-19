import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/repositories/game_usage_repositories.dart';

final class PlayGameUseCase {
  const PlayGameUseCase({required this.repository});

  final GameUsageRepository repository;

  Future<void> call(GameCategory category, {bool paidWithCoin = false}) async {
    final date = DateTime.now();

    if (paidWithCoin) {
      // Coin ilə ödəniş olunubsa günlük limitə toxunulmur
      return;
    }

    final flexibleGames = repository.getFlexibleGamesCount(date);
    if (flexibleGames > 0) {
      // Əgər flexible game varsa, ondan 1 dənə düşürük
      await repository.setFlexibleGamesCount(date, flexibleGames - 1);
    } else {
      // Əgər flexible game yoxdursa, günlük limit sayını artırırıq
      final currentRequests = repository.getDailyRequestCount(category, date);
      await repository.setDailyRequestCount(category, date, currentRequests + 1);
    }
  }
}
