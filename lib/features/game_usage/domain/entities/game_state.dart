import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zifromania/core/errors/app_exception.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/game_usage/domain/entities/math_question.dart';
import 'package:zifromania/features/title/data/models/title_model.dart';

part 'game_state.freezed.dart';

@freezed
abstract class GameState with _$GameState {
  const GameState._();

  const factory GameState({
    @Default([]) List<MathQuestion> questions,
    @Default(0) int currentQuestionIndex,
    @Default(0) int score,
    @Default(0) int xpEarned,
    @Default(0) int secondsRemaining,
    @Default(false) bool isLoading,
    @Default(false) bool isGameActive,
    int? lastSelectedAnswer,
    int? lastAnsweredQuestionIndex,
    bool? isLastAnswerCorrect,
    AppException? appException,
    DateTime? gameStartTime,
    @Default(false) bool showResultDialog,
    GameCategory? gameCategory,
    @Default([]) List<TitleModel> newlyEarnedTitles,
  }) = _GameState;

  MathQuestion? get currentQuestion =>
      currentQuestionIndex < questions.length ? questions[currentQuestionIndex] : null;
}
