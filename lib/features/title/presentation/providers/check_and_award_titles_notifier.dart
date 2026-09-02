import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/title/title_module.dart';
import 'package:zifromania/features/title/presentation/providers/user_titles_notifier.dart';

/// Oyun sona çatdıqdan sonra çağırılır: istifadəçinin yeni qazandığı
/// title id-lərinin siyahısını saxlayır (məs. bir badge/dialog göstərmək üçün).
final checkAndAwardTitlesProvider = AsyncNotifierProvider<CheckAndAwardTitlesNotifier, List<String>>(
  CheckAndAwardTitlesNotifier.new,
);

final class CheckAndAwardTitlesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => const [];

  Future<List<String>> check({
    required String userId,
    required int lastGameScore,
    required int incorrectAnswers,
    required int averageTimePerQuestion,
    required int questionsAnswered,
    required String category,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() {
      return ref.read(checkAndAwardTitlesUseCaseProvider).call(
            userId: userId,
            lastGameScore: lastGameScore,
            incorrectAnswers: incorrectAnswers,
            averageTimePerQuestion: averageTimePerQuestion,
            questionsAnswered: questionsAnswered,
            category: category,
          );
    });

    state = result;

    final newTitleIds = result.maybeWhen(
      data: (titleIds) => titleIds,
      orElse: () => const <String>[],
    );
    if (newTitleIds.isNotEmpty) {
      // Yeni title(lar) qazanılıbsa, əlaqəli provider-ləri təzələyirik
      ref.invalidate(userTitlesProvider(userId));
    }

    return newTitleIds;
  }
}
