import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/core/utils/cancel_token.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_config.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_state.dart';
import 'package:zifromania/features/game_usage/game_usage_module.dart';

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  CancelToken? _cancelToken;
  GameConfig? _config;

  @override
  GameState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _cancelToken?.cancel();
    });
    return const GameState();
  }

  Future<void> start(
    String userId, {
    required GameCategory category,
    required bool paidWithCoin,
  }) async {
    _config = (category: category, paidWithCoin: paidWithCoin);

    _timer?.cancel();
    _cancelToken?.cancel();
    final token = _cancelToken = CancelToken();
    state = GameState(isLoading: true, secondsRemaining: _startingSeconds, gameCategory: category);

    try {
      final questions = await ref.read(generateQuestionsUseCaseProvider).call(
            gameCategory: category,
            userId: userId,
            cancelToken: token,
            paidWithCoin: paidWithCoin,
          );
      if (token.isCancelled) return;
      ref.invalidate(categoryStatsProvider(category));
      state = state.copyWith(
          questions: questions,
          isLoading: false,
          isGameActive: true,
          gameStartTime: DateTime.now());
      if (category != GameCategory.training) _startTimer();
    } on AppException catch (error) {
      if (!token.isCancelled) state = state.copyWith(isLoading: false, appException: error);
    } catch (error) {
      if (!token.isCancelled)
        state = state.copyWith(
            isLoading: false, appException: UnknownException(message: error.toString()));
    }
  }

  void checkAnswer(int selectedAnswerIndex) {
    final question = state.currentQuestion;
    if (!state.isGameActive ||
        question == null ||
        state.lastAnsweredQuestionIndex == state.currentQuestionIndex) return;

    final values = question.answerOptions.values.toList();
    final selectedValue = values[selectedAnswerIndex];
    final isCorrect = int.tryParse(selectedValue) == question.correctAnswer ||
        (selectedValue == 'True' && question.correctAnswer == 1) ||
        (selectedValue == 'False' && question.correctAnswer == 0);
    state = state.copyWith(
      score: isCorrect ? state.score + 1 : state.score,
      xpEarned: isCorrect ? state.xpEarned + 1 : state.xpEarned,
      lastSelectedAnswer: selectedAnswerIndex,
      lastAnsweredQuestionIndex: state.currentQuestionIndex,
      isLastAnswerCorrect: isCorrect,
    );

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (state.isGameActive && state.lastAnsweredQuestionIndex == state.currentQuestionIndex)
        _nextQuestion();
    });
  }

  Future<void> playAgain(String userId) {
    final config = _config;
    if (config == null) return Future<void>.value();
    return start(userId, category: config.category, paidWithCoin: config.paidWithCoin);
  }

  void cancelCurrentOperation() {
    _timer?.cancel();
    _cancelToken?.cancel();
  }

  int get _startingSeconds => switch (_config!.category) {
        GameCategory.trueOrFalse => 5,
        GameCategory.expert => 120,
        GameCategory.training => 0,
        _ => 60,
      };

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining <= 1) {
        if (_config?.category == GameCategory.trueOrFalse) {
          _nextQuestion();
        } else {
          _timer?.cancel();
          _finishGame();
        }
      } else {
        state = state.copyWith(
          secondsRemaining: state.secondsRemaining - 1,
          lastSelectedAnswer: state.lastSelectedAnswer,
          lastAnsweredQuestionIndex: state.lastAnsweredQuestionIndex,
          isLastAnswerCorrect: state.isLastAnswerCorrect,
        );
      }
    });
  }

  void _nextQuestion() {
    if (state.currentQuestionIndex + 1 >= state.questions.length) {
      _finishGame();
      return;
    }
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      secondsRemaining:
          _config?.category == GameCategory.trueOrFalse ? _startingSeconds : state.secondsRemaining,
    );
  }

  void _finishGame() {
    _timer?.cancel();
    state = state.copyWith(isGameActive: false, showResultDialog: true);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
