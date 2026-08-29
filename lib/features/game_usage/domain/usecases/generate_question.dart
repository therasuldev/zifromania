// features/game/domain/usecases/generate_questions_usecase.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/app_exception.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'package:zifromania/features/game_usage/domain/repositories/question_repository.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import 'package:zifromania/presentation/state-managment/game/game_bloc.dart';

import 'can_play_game_usecase.dart';
import 'play_game_usecase.dart';

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
    // 1. Cancel Token yoxlanışı
    if (cancelToken?.isCancelled == true) {
      throw Exception('Operation cancelled');
    }

    // 2. Oynamaq hüququnun yoxlanılması
    final canPlay = canPlayGameUseCase(gameCategory, willPayWithCoin: paidWithCoin);
    if (!canPlay) {
      throw AppException(
        AppErrorType.dailyLimitReached,
        'game.limit_reached'.tr(),
      );
    }

    // 3. Əgər Coin ilə ödəmə seçilibsə, balansı çıxmaq
    if (paidWithCoin) {
      await userRepository.spendCoins(uid: userId, amount: coinCost);
    }

    // 4. Fayldan sualları yükləmək
    final allQuestions = await questionRepository.getQuestions(gameCategory);

    // 5. 7 saniyəlik süni gözləmə (Cancel Token dəstəyi ilə)
    for (int i = 0; i < 70; i++) {
      if (cancelToken?.isCancelled == true) {
        throw Exception('Operation cancelled');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (cancelToken?.isCancelled == true) {
      throw Exception('Operation cancelled');
    }

    // 6. Oynanış limit statistikalarını yeniləmək
    await playGameUseCase(gameCategory, paidWithCoin: paidWithCoin);

    // 7. Sualları qarışdırıb qaytarmaq
    final list = List<MathQuestion>.from(allQuestions)..shuffle();
    return list.take(questionCount).toList();
  }
}
