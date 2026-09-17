import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/core/utils/cancel_token.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'package:zifromania/features/game_usage/domain/repositories/question_repository.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/game_usage/domain/usecases/can_play_game_usecase.dart';
import 'package:zifromania/features/game_usage/domain/usecases/play_game_usecase.dart';

final class GenerateQuestionsUseCase {
  const GenerateQuestionsUseCase({
    required this.questionRepository,
    required this.canPlayGameUseCase,
    required this.playGameUseCase,
    required this.userRepository,
  });

  final QuestionRepository questionRepository;
  final CanPlayGameUseCase canPlayGameUseCase;
  final PlayGameUseCase playGameUseCase;
  final UserRepository userRepository;

  Future<List<MathQuestion>> call({
    required GameCategory gameCategory,
    required String userId,
    int questionCount = 15,
    CancelToken? cancelToken,
    bool paidWithCoin = false,
    int coinCost = 10,
  }) async {
    // 1. Check at the beginning of the operation
    cancelToken?.throwIfCancelled();

    // 2. Check whether the user can play
    final canPlay = canPlayGameUseCase(gameCategory, willPayWithCoin: paidWithCoin);
    if (!canPlay) {
      throw DailyLimitReachedException(
        message: 'game.limit_reached'.tr(),
      );
    }

    // 3. Preload questions before deducting coins
    final allQuestions = await questionRepository.getQuestions(gameCategory);
    cancelToken?.throwIfCancelled();

    // 4. Brief artificial delay
    for (int i = 0; i < 30; i++) {
      if (cancelToken?.isCancelled == true) {
        throw const OperationCanceledException();
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    // Final check before deducting coins
    cancelToken?.throwIfCancelled();

    // 5. Deduct coins and update usage statistics only after everything succeeds
    if (paidWithCoin) {
      await userRepository.spendCoins(uid: userId, amount: coinCost);
    }

    await playGameUseCase(gameCategory, paidWithCoin: paidWithCoin);

    // 6. Return the questions
    final list = List<MathQuestion>.from(allQuestions)..shuffle();
    return list.take(questionCount).toList();
  }
}
