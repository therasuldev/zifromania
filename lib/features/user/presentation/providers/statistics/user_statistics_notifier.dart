import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/user/data/models/game_update_data.dart';
import 'package:zifromania/features/user/user_module.dart';

// ---------------------------------------------------------------------------
// READ PROVIDERS
// ---------------------------------------------------------------------------

/// İstifadəçinin cari streak-ini gətirir.
final currentStreakProvider = FutureProvider.family<int, String>(
  (ref, uid) {
    final getCurrentStreak = ref.watch(getCurrentStreakUseCaseProvider);

    return getCurrentStreak(uid);
  },
);

/// İstifadəçinin oynadığı fərqli kateqoriyaları gətirir.
final distinctCategoriesPlayedProvider = FutureProvider.family<Set<String>, String>(
  (ref, uid) {
    final getDistinctCategoriesPlayed = ref.watch(getDistinctCategoriesPlayedUseCaseProvider);

    return getDistinctCategoriesPlayed(uid);
  },
);

/// Konkret bir kateqoriya üzrə orta sual vaxtını gətirir.
/// Parametr kimi (uid, category) record istifadə olunur.
final categoryAverageTimeProvider = FutureProvider.family<double, ({String uid, String category})>(
  (ref, params) {
    final getCategoryAverageTime = ref.watch(getCategoryAverageTimeUseCaseProvider);

    return getCategoryAverageTime(
      uid: params.uid,
      category: params.category,
    );
  },
);

// ---------------------------------------------------------------------------
// ACTIONS NOTIFIER
// ---------------------------------------------------------------------------

/// Statistika ilə bağlı mutasiya (action) əməliyyatlarını idarə edir:
/// oyun statistikasının yenilənməsi, günlük streak, achievement əlavə etmə.
class UserStatisticsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateGameStatistics({
    required String uid,
    required GameUpdateData data,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateGameStatisticsUseCaseProvider).call(uid: uid, data: data);
    });
  }

  Future<void> updateDailyStreak(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateDailyStreakUseCaseProvider).call(uid);
    });

    // Streak yeniləndikdən sonra oxuma provider-ini təzələmək faydalıdır.
    ref.invalidate(currentStreakProvider);
  }

  Future<void> addAchievement({
    required String uid,
    required String achievementId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addAchievementUseCaseProvider).call(
            uid: uid,
            achievementId: achievementId,
          );
    });
  }
}

final userStatisticsProvider = AsyncNotifierProvider<UserStatisticsNotifier, void>(UserStatisticsNotifier.new);
