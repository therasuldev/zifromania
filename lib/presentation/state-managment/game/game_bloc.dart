import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/app_exception.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'package:zifromania/services/audio_service.dart';
import 'package:zifromania/services/question_service.dart';
import 'package:zifromania/services/title_service.dart';
import 'package:zifromania/services/user_service.dart';
import 'package:zifromania/services/xp_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

class GameBloc extends Bloc<GameEvent, GameState> {
  static const int MAX_INCORRECT_ANSWERS = 4;
  static const int QUICK_THINKING_TIME = 30;
  static const int MULTIPLY_DIVIDE_TIME = 30;
  static const int TRUE_OR_FALSE_PER_QUESTION_TIME = 3;
  static const int EXPERT_MODE_TIME = 60;
  static const int TRAINING_MODE_QUESTIONS = 500;

  final AuthService _authService;
  final SecureCacheService _cacheService;
  final UserService _userService;
  final AudioService _audioService;
  final QuestionService _questionService;
  final TitleService _titleService;
  final InAppPurchaseService _inAppPurchaseService;

  Timer? _gameTimer;
  Timer? _questionTimer; // For True/False mode per-question timer
  CancelToken? _currentCancelToken;

  GameBloc({
    required AuthService authService,
    required SecureCacheService cacheService,
    required UserService userService,
    required AudioService audioService,
    required QuestionService questionService,
    required TitleService titleService,
    required InAppPurchaseService inAppPurchaseService,
  })  : _authService = authService,
        _cacheService = cacheService,
        _userService = userService,
        _audioService = audioService,
        _questionService = questionService,
        _titleService = titleService,
        _inAppPurchaseService = inAppPurchaseService,
        super(GameState.initial()) {
    on<GameEvent>((event, emit) async {
      switch (event.type) {
        case GameEvents.startGame:
          await _onStartGame(event, emit);
          break;
        case GameEvents.endGame:
          await _onEndGame(emit);
          break;
        case GameEvents.timerTick:
          await _onTimerTick(emit);
          break;
        case GameEvents.autoAdvanceQuestion:
          await _onAutoAdvanceQuestion(emit);
          break;
        case GameEvents.checkAnswer:
          final q = event.payload['question'] as MathQuestion;
          final i = event.payload['selectedAnswerIndex'] as int;
          await _onCheckAnswer(q, i, emit);
          break;
        case GameEvents.resetGame:
          await _onResetGame(emit);
          break;
        case GameEvents.showNextQuestion:
          _onShowNextQuestion(emit);
          break;
        case GameEvents.playAgain:
          await _onPlayAgain(event, emit);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _onStartGame(GameEvent event, Emitter<GameState> emit) async {
    final gameCategory = event.payload['category'] as GameCategory;
    final paidWithCoin = event.payload['paidWithCoin'] as bool? ?? false;
    final haveEnoughCoins = event.payload['haveEnoughCoins'] as bool? ?? false;

    if (!haveEnoughCoins && paidWithCoin) {
      // Əgər kifayət qədər coin yoxdursa, istifadəçiyə xəbərdarlıq et və oyunu başlatma
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'coin.notEnoughCoins'.tr(),
        appException: AppException(
          AppErrorType.notEnoughCoins,
          'coin.notEnoughCoins'.tr(),
        ),
        isGameActive: false,
      ));
      return;
    }

    // Əvvəlki prosesi cancel et
    _currentCancelToken?.cancel();

    // Yeni cancel token yarat
    _currentCancelToken = CancelToken();
    final currentToken = _currentCancelToken!;

    _gameTimer?.cancel();
    _questionTimer?.cancel();

    // 🆕 Əgər coin ilə oyun başladılıbsa, coin-dən çıx
    if (paidWithCoin) {
      try {
        final (success, uid) = await _cacheService.decreaseUserCoins(10);
        await _userService.spendCoins(uid, 10);
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'coin.coin_balance_update_error'.tr(),
          appException: AppException(AppErrorType.unknown, e.toString()),
          isGameActive: false,
        ));
        return;
      }
    }

    // Set initial game state based on gameCategory
    int startingTime;
    bool useQuestionTimer = false;

    switch (gameCategory) {
      case GameCategory.quickThinking:
        startingTime = QUICK_THINKING_TIME;
        break;
      case GameCategory.multiplyDivide:
        startingTime = MULTIPLY_DIVIDE_TIME;
        break;
      case GameCategory.trueOrFalse:
        startingTime = TRUE_OR_FALSE_PER_QUESTION_TIME;
        useQuestionTimer = true;
        break;
      case GameCategory.expert:
        startingTime = EXPERT_MODE_TIME;
        break;
      case GameCategory.training:
        startingTime = 0; // No time limit
        break;
    }

    emit(GameState.initial().copyWith(
      isLoading: true,
      gameCategory: gameCategory,
      secondsRemaining: startingTime,
      useQuestionTimer: useQuestionTimer,
    ));

    try {
      // Generate questions based on selected gameCategory
      List<MathQuestion> questions = await _questionService.generateQuestions(
        gameCategory,
        paidWithCoin: paidWithCoin,
        cancelToken: currentToken,
      );

      // Əgər cancel olunubsa, davam etmə
      if (currentToken.isCancelled) {
        if (paidWithCoin) {
          final (success, uid) = await _cacheService.increaseUserCoins(10);
          await _userService.addCoins(uid, 10);
        }
        return;
      }

      // Start the timer based on mode
      if (gameCategory != GameCategory.training) {
        if (useQuestionTimer) {
          await _startQuestionTimer();
        } else {
          await _startTimer();
        }
      }

      // Yenə cancel yoxla
      if (currentToken.isCancelled) {
        if (paidWithCoin) {
          final (success, uid) = await _cacheService.increaseUserCoins(10);
          await _userService.addCoins(uid, 10);
        }
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        questions: questions,
        isGameActive: true,
        gameStartTime: DateTime.now(),
      ));
    } on AppException catch (exp) {
      if (!currentToken.isCancelled) {
        if (paidWithCoin) {
          final (success, uid) = await _cacheService.increaseUserCoins(10);
          await _userService.addCoins(uid, 10);
        }
        emit(state.copyWith(
          isLoading: false,
          appException: exp,
          errorMessage: exp.message,
          isGameActive: false,
        ));
      }
    } catch (exp) {
      if (!currentToken.isCancelled) {
        if (paidWithCoin) {
          final (success, uid) = await _cacheService.increaseUserCoins(10);
          await _userService.addCoins(uid, 10);
        }
        emit(state.copyWith(
          isLoading: false,
          appException: AppException(AppErrorType.unknown, exp.toString()),
          errorMessage: exp.toString(),
          isGameActive: false,
        ));
      }
    }
  }

  void cancelCurrentOperation() {
    _currentCancelToken?.cancel();
  }

  // Add this new method for True/False mode
  Future<void> _startQuestionTimer() async {
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 1) {
        add(GameEvent.timerTick());
      } else {
        // Auto advance to next question when time is up
        _questionTimer?.cancel();
        final nextIndex = state.currentQuestionIndex + 1;

        if (nextIndex < state.questions.length) {
          add(GameEvent.autoAdvanceQuestion());
        } else {
          add(GameEvent.endGame());
        }
      }
    });
  }

  // Add new event handler for auto-advancing question
  Future<void> _onAutoAdvanceQuestion(Emitter<GameState> emit) async {
    final nextIndex = state.currentQuestionIndex + 1;

    if (nextIndex < state.questions.length) {
      emit(state.copyWith(
        currentQuestionIndex: nextIndex,
        lastSelectedAnswer: null,
        isLastAnswerCorrect: null,
        secondsRemaining: TRUE_OR_FALSE_PER_QUESTION_TIME, // Reset timer for next question
      ));
      await _startQuestionTimer(); // Restart timer for next question
    } else {
      await _onEndGame(emit);
    }
  }

  Future<void> _onCheckAnswer(MathQuestion question, int selectedIndex, Emitter<GameState> emit) async {
    if (!state.isGameActive) return;

    // If using question timer (True/False mode), cancel the timer
    if (state.useQuestionTimer) {
      _questionTimer?.cancel();
    }

    // Determine correctness based on new Map<String, String> format
    bool isCorrect = false;

    // Get the option keys (A, B, C, D) as a list
    final optionKeys = question.answerOptions.keys.toList();

    // Make sure selectedIndex is valid
    if (selectedIndex < 0 || selectedIndex >= optionKeys.length) {
      // Invalid selection, treat as incorrect
      isCorrect = false;
    } else {
      // Get the selected option key (A, B, C, D)
      final selectedOptionKey = optionKeys[selectedIndex];

      // Check if this is True/False question
      if (question.answerOptions.values.contains('True') && question.answerOptions.values.contains('False')) {
        // True/False logic
        final selectedAnswer = question.answerOptions[selectedOptionKey]!;
        final correctIsTrue = question.correctAnswer == 1;
        isCorrect = (selectedAnswer == "True" && correctIsTrue) || (selectedAnswer == "False" && !correctIsTrue);
      } else {
        // Multiple choice numeric questions
        final selectedAnswerString = question.answerOptions[selectedOptionKey]!;

        // Try to parse the selected answer as integer
        final selectedAnswerInt = int.tryParse(selectedAnswerString);

        if (selectedAnswerInt != null) {
          isCorrect = selectedAnswerInt == question.correctAnswer;
        } else {
          // If can't parse as int, compare as string with correctAnswer
          isCorrect = selectedAnswerString == question.correctAnswer.toString();
        }
      }
    }

    // Update score & incorrect count (except in endless mode)
    int newScore = state.score;
    int newIncorrect = state.incorrectAnswersCount;
    if (state.gameCategory != GameCategory.training) {
      if (isCorrect) {
        newScore++;
      } else {
        newIncorrect++;
        if (newIncorrect >= GameBloc.MAX_INCORRECT_ANSWERS) {
          newScore = max(0, newScore - (state.gameCategory == GameCategory.expert ? 2 : 1));
          newIncorrect = 0;
        }
      }
    }

    // Emit feedback for this question
    emit(state.copyWith(
      score: newScore,
      incorrectAnswersCount: newIncorrect,
      lastSelectedAnswer: selectedIndex,
      isLastAnswerCorrect: isCorrect,
      lastAnsweredQuestionIndex: state.currentQuestionIndex,
    ));

    // Play sound & wait for animation
    await _audioService.reset();
    await _audioService.playSoundEffect(isCorrect);
    await Future.delayed(const Duration(milliseconds: 500));

    // Advance or end game
    if (!state.isGameActive) {
      // Game already ended elsewhere
      emit(state.copyWith(
        lastSelectedAnswer: null,
        isLastAnswerCorrect: null,
      ));
      return;
    }

    final nextIndex = state.currentQuestionIndex + 1;

    if (state.gameCategory == GameCategory.training) {
      // Endless mode: only one free run, then require subscription
      if (nextIndex < state.questions.length) {
        // Still have preloaded questions: just advance
        emit(state.copyWith(
          currentQuestionIndex: nextIndex,
          lastSelectedAnswer: null,
          isLastAnswerCorrect: null,
        ));
      } else {
        // Ran out of questions: check subscription
        if (_inAppPurchaseService.hasActiveSubscription) {
          // Premium user: generate more questions and advance
          try {
            List<MathQuestion> more = await _questionService.generateQuestions(state.gameCategory!);
            emit(state.copyWith(
              questions: [...state.questions, ...more],
              currentQuestionIndex: nextIndex,
              lastSelectedAnswer: null,
              isLastAnswerCorrect: null,
            ));
          } catch (e) {
            emit(state.copyWith(errorMessage: 'Failed to load more questions: $e'));
            await _onEndGame(emit);
          }
        } else {
          // Non-premium: prompt for subscription
          emit(state.copyWith(
            isGameActive: false,
            showSubscribeDialog: true,
          ));
        }
      }
      return;
    }

    // Non-endless modes: standard advance or end
    if (nextIndex < state.questions.length) {
      if (state.useQuestionTimer && state.gameCategory == GameCategory.trueOrFalse) {
        emit(state.copyWith(
          currentQuestionIndex: nextIndex,
          lastSelectedAnswer: null,
          isLastAnswerCorrect: null,
          secondsRemaining: TRUE_OR_FALSE_PER_QUESTION_TIME,
        ));
        await _startQuestionTimer();
      } else {
        emit(state.copyWith(
          currentQuestionIndex: nextIndex,
          lastSelectedAnswer: null,
          isLastAnswerCorrect: null,
        ));
      }
    } else {
      await _onEndGame(emit);
    }
  }

  Future<void> _onPlayAgain(GameEvent event, Emitter<GameState> emit) async {
    await _onStartGame(event, emit);
  }

  Future<void> _onResetGame(Emitter<GameState> emit, {GameCategory? gameCategory, bool? isLoading}) async {
    _gameTimer?.cancel();
    _questionTimer?.cancel();
    emit(GameState.initial().copyWith(gameCategory: gameCategory, isLoading: isLoading));
  }

  Future<void> _startTimer() async {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(GameEvent.timerTick());
    });
  }

  // First, add this new method for handling timer ticks specifically for True/False mode
  Future<void> _onTimerTick(Emitter<GameState> emit) async {
    if (state.useQuestionTimer && state.gameCategory == GameCategory.trueOrFalse) {
      if (state.secondsRemaining > 0) {
        emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      } else {
        add(GameEvent.autoAdvanceQuestion());
      }
    } else {
      // standart global timer davranışı
      if (state.secondsRemaining > 0) {
        emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      } else {
        add(GameEvent.endGame());
      }
    }
  }

  // Complete _onEndGame function
  Future<void> _onEndGame(Emitter<GameState> emit) async {
    _gameTimer?.cancel();
    _questionTimer?.cancel();

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    // Determine XP earned based on gameCategory
    int multiplier = switch (state.gameCategory) { GameCategory.multiplyDivide || GameCategory.expert => 2, _ => 1 };

    // Calculate XP using the service
    final int xp = XpService.calculateGameXp(
      correctAnswers: state.score,
      wrongAnswers: state.incorrectAnswersCount,
      multiplier: multiplier,
    );

    List<TitleModel> newlyEarnedTitles = [];

    try {
      // 1️⃣ Update XP and handle level up
      await _userService.addXpAndHandleLevelUp(uid, xp);

      // 2️⃣ Update daily streak
      await _userService.updateDailyStreak(uid);

      // 3️⃣ Update game statistics
      await _updateGameStatistics(uid);

      // 4️⃣ Check for newly earned titles
      newlyEarnedTitles = await _checkAndAwardTitles(uid);
    } catch (e) {
      logger.log('Game end update failed: $e');
    }

    emit(
      state.copyWith(
        xpEarned: xp,
        isGameActive: false,
        showResultDialog: true,
        newlyEarnedTitles: newlyEarnedTitles,
      ),
    );
  }

  /// Update game statistics after game ends
  Future<void> _updateGameStatistics(String uid) async {
    if (state.gameStartTime == null) return;

    final gameEndTime = DateTime.now();
    final gameDurationSeconds = gameEndTime.difference(state.gameStartTime!).inSeconds;
    final categoryString = _getCategoryString(state.gameCategory);

    await _userService.updateGameStatistics(
      uid: uid,
      category: categoryString,
      score: state.score,
      questionsAnswered: state.score + state.incorrectAnswersCount,
      correctAnswers: state.score,
      gameTimeInSeconds: gameDurationSeconds,
    );
  }

  /// Check for newly earned titles and award them
  Future<List<TitleModel>> _checkAndAwardTitles(String uid) async {
    try {
      // Get current user data (refreshed after updates)
      final user = await _userService.fetchFullUser(uid);

      // Get all available titles
      final allTitles = await _titleService.getAllTitles();

      List<TitleModel> newTitles = [];

      for (final title in allTitles) {
        // Skip if user already has this title
        if (user.achievements.contains(title.id)) continue;

        // Check if user meets requirements for this title
        bool meetsRequirements = await _checkTitleRequirements(title.requirements, user, uid);

        if (meetsRequirements) {
          // Award the title
          await _titleService.awardTitleToUser(uid, title.id);
          newTitles.add(title);
          logger.log('Title awarded: ${title.name}');
        }
      }

      return newTitles;
    } catch (e) {
      logger.log('Error checking titles: $e');
      return [];
    }
  }

  /// Check if user meets specific title requirements
  Future<bool> _checkTitleRequirements(Map<String, dynamic> requirements, UserModel user, String uid) async {
    for (var entry in requirements.entries) {
      final key = entry.key;
      final value = entry.value;

      switch (key) {
        case 'score':
          if (state.score < value) return false;
          break;

        case 'level':
          if (user.level < value) return false;
          break;

        case 'levelExact':
          if (user.level != value) return false;
          break;

        case 'incorrectAnswers':
          if (state.incorrectAnswersCount > value) return false;
          break;

        case 'isPremium':
          if (user.hasActiveSubscription != value) return false;
          break;

        case 'category':
          final currentCategory = _getCategoryString(state.gameCategory);
          if (currentCategory != value) return false;
          break;

        case 'questionsAnswered':
          final totalQuestions = state.score + state.incorrectAnswersCount;
          if (totalQuestions < value) return false;
          break;

        case 'dailyStreak':
          if (user.currentStreak < value) return false;
          break;

        case 'averageTimePerQuestion':
          // Check current game's average time
          final currentGameAvgTime = await _calculateCurrentGameAverageTime();
          if (currentGameAvgTime > value) return false;
          break;

        default:
          break;
      }
    }
    return true;
  }

  /// Calculate average time per question for current game
  Future<double> _calculateCurrentGameAverageTime() async {
    if (state.gameStartTime == null) return 0.0;

    final gameEndTime = DateTime.now();
    final gameDurationSeconds = gameEndTime.difference(state.gameStartTime!).inSeconds;
    final totalQuestions = state.score + state.incorrectAnswersCount;

    return totalQuestions > 0 ? gameDurationSeconds / totalQuestions : 0.0;
  }

  /// Convert GameCategory to category string
  String _getCategoryString(GameCategory? gameCategory) {
    if (gameCategory == null) return 'unknown';

    return switch (gameCategory) {
      GameCategory.quickThinking => 'quickThinking',
      GameCategory.multiplyDivide => 'multiplyDivide',
      GameCategory.trueOrFalse => 'trueOrFalse',
      GameCategory.expert => 'expert',
      GameCategory.training => 'training',
    };
  }

  void _onShowNextQuestion(Emitter<GameState> emit) {
    logger.log("_onShowNextQuestion çağırıldı, amma artıq istifadə olunmur");
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _questionTimer?.cancel();
    // _audioService.dispose();
    return super.close();
  }
}
