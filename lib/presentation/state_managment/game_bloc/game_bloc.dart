import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equation_quest/domain/entities/enums.dart';
import 'package:equation_quest/domain/entities/math_question.dart';
import 'package:equation_quest/services/audio_service.dart';
import 'package:equation_quest/services/open_ai_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const int MAX_INCORRECT_ANSWERS = 4;
  static const int SPEED_CALCULATION_TIME = 60;
  static const int MULTIPLICATION_TABLE_TIME = 60;
  static const int TRUE_FALSE_PER_QUESTION_TIME = 3;
  static const int EXPERT_MODE_TIME = 120;
  static const int TRAINING_MODE_QUESTIONS = 100;

  final AudioService _audioService = AudioService();
  final OpenAIService _openAIService = OpenAIService.instance;

  Timer? _gameTimer;
  Timer? _questionTimer; // For True/False mode per-question timer

  GameBloc() : super(GameState.initial()) {
    on<GameEvent>((event, emit) async {
      switch (event.type) {
        case GameEvents.startGame:
          await _onStartGame(event.payload as GameDifficulty, emit);
          break;
        case GameEvents.endGame:
          _onEndGame(emit);
          break;
        case GameEvents.timerTick:
          _onTimerTick(emit);
          break;
        case GameEvents.autoAdvanceQuestion:
          _onAutoAdvanceQuestion(emit);
          break;
        case GameEvents.checkAnswer:
          final q = event.payload['question'] as MathQuestion;
          final i = event.payload['selectedAnswerIndex'] as int;
          await _onCheckAnswer(q, i, emit);
          break;
        case GameEvents.resetGame:
          _onResetGame(emit);
          break;
        case GameEvents.showNextQuestion:
          _onShowNextQuestion(emit);
          break;
        case GameEvents.playAgain:
          await _onPlayAgain(event.payload as GameDifficulty, emit);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _onStartGame(GameDifficulty difficulty, Emitter<GameState> emit) async {
    _gameTimer?.cancel();
    _questionTimer?.cancel();

    // Set initial game state based on difficulty
    int startingTime;
    bool useQuestionTimer = false;

    switch (difficulty) {
      case GameDifficulty.speedCalculation:
        startingTime = SPEED_CALCULATION_TIME;
        break;
      case GameDifficulty.multiplyDivideBattle:
        startingTime = MULTIPLICATION_TABLE_TIME;
        break;
      case GameDifficulty.trueFalse:
        startingTime = TRUE_FALSE_PER_QUESTION_TIME;
        useQuestionTimer = true;
        break;
      case GameDifficulty.expert:
        startingTime = EXPERT_MODE_TIME;
        break;
      case GameDifficulty.endless:
        startingTime = 0; // No time limit
        break;
      default:
        startingTime = SPEED_CALCULATION_TIME;
    }

    emit(GameState.initial().copyWith(
      isLoading: true,
      difficulty: difficulty,
      secondsRemaining: startingTime,
      useQuestionTimer: useQuestionTimer,
    ));

    try {
      // Generate questions based on selected difficulty
      List<MathQuestion> questions = await _openAIService.generateQuestions(difficulty);

      // Start the timer based on mode
      if (difficulty != GameDifficulty.endless) {
        if (useQuestionTimer) {
          _startQuestionTimer();
        } else {
          _startTimer();
        }
      }

      emit(state.copyWith(
        isLoading: false,
        questions: questions,
        isGameActive: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        isGameActive: false,
      ));
    }
  }

  // Add this new method for True/False mode
  void _startQuestionTimer() {
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
  void _onAutoAdvanceQuestion(Emitter<GameState> emit) {
    final nextIndex = state.currentQuestionIndex + 1;

    if (nextIndex < state.questions.length) {
      emit(state.copyWith(
        currentQuestionIndex: nextIndex,
        lastSelectedAnswer: null,
        isLastAnswerCorrect: null,
        secondsRemaining: TRUE_FALSE_PER_QUESTION_TIME, // Reset timer for next question
      ));
      _startQuestionTimer(); // Restart timer for next question
    } else {
      _onEndGame(emit);
    }
  }

  Future<void> _onCheckAnswer(MathQuestion question, int selectedIndex, Emitter<GameState> emit) async {
    if (!state.isGameActive) return;

    // If using question timer (True/False mode), cancel the timer
    if (state.useQuestionTimer) {
      _questionTimer?.cancel();
    }

    bool isCorrect;

    // Check if this is a true/false question
    if (question.answerOptions.isNotEmpty &&
        question.answerOptions.first is String &&
        (question.answerOptions.first == "True" || question.answerOptions.first == "False")) {
      // For true/false questions
      final String selectedAnswer = question.answerOptions[selectedIndex].toString();
      final bool correctIsTrue = question.correctAnswer == 1; // 1 means True, 0 means False
      isCorrect = (selectedAnswer == "True" && correctIsTrue) || (selectedAnswer == "False" && !correctIsTrue);
    } else {
      // For numeric questions - use the original comparison
      isCorrect = question.answerOptions[selectedIndex] == question.correctAnswer;
    }

    // Cari score və səhv cavab sayını alırıq
    int newScore = state.score;
    int newIncorrect = state.incorrectAnswersCount;

    // Əgər cavab doğrudursa score-u artırırıq, əks halda səhv sayını artırırıq
    if (state.difficulty != GameDifficulty.endless) {
      if (isCorrect) {
        newScore++;
      } else {
        newIncorrect++;
        if (newIncorrect >= GameBloc.MAX_INCORRECT_ANSWERS) {
          newScore = max(0, newScore - 1);
          newIncorrect = 0;
        }
      }
    }

    // Cavab seçimindən dərhal sonra feedback göstəririk
    emit(state.copyWith(
      score: newScore,
      incorrectAnswersCount: newIncorrect,
      lastSelectedAnswer: selectedIndex,
      isLastAnswerCorrect: isCorrect,
      lastAnsweredQuestionIndex: state.currentQuestionIndex,
    ));

    _audioService.reset();
    _audioService.playSoundEffect(isCorrect);

    // UI-nin feedback animasiyasını tamamlaması üçün delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (state.isGameActive) {
      final nextIndex = state.currentQuestionIndex + 1;

      if (nextIndex < state.questions.length) {
        // Check if we need to regenerate questions for Training Mode
        if (state.difficulty == GameDifficulty.endless && nextIndex >= state.questions.length - 5) {
          _checkAndRegenerateQuestions(emit);
        }

        // Different handling based on difficulty mode
        if (state.useQuestionTimer && state.difficulty == GameDifficulty.trueFalse) {
          // For True/False mode: Reset timer for next question
          emit(state.copyWith(
            currentQuestionIndex: nextIndex,
            lastSelectedAnswer: null,
            isLastAnswerCorrect: null,
            secondsRemaining: TRUE_FALSE_PER_QUESTION_TIME, // Reset timer for next question
          ));
          _startQuestionTimer(); // Restart timer for next question
        } else {
          // Standard mode: just advance to next question
          emit(state.copyWith(
            currentQuestionIndex: nextIndex,
            lastSelectedAnswer: null,
            isLastAnswerCorrect: null,
          ));
        }

        logger.log("Növbəti suala keçid: $nextIndex, lastSelectedAnswer: null oldu");
      } else {
        // Əgər suallar bitibsə
        _onEndGame(emit);
      }
    } else {
      // Oyun artıq aktiv deyilsə, sadəcə state-i sıfırlayaq
      emit(state.copyWith(
        lastSelectedAnswer: null,
        isLastAnswerCorrect: null,
      ));
    }
  }

  // For Training Mode, add question regeneration
  void _checkAndRegenerateQuestions(Emitter<GameState> emit) async {
    if (state.difficulty == GameDifficulty.endless && state.currentQuestionIndex >= state.questions.length - 5) {
      // Regenerate questions when we're close to running out
      try {
        List<MathQuestion> newQuestions = await _openAIService.generateQuestions(state.difficulty!);
        emit(state.copyWith(
          questions: [...state.questions, ...newQuestions],
        ));
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Failed to load more questions: ${e.toString()}'));
      }
    }
  }

  Future<void> _onPlayAgain(GameDifficulty difficulty, Emitter<GameState> emit) async {
    _onResetGame(emit, difficulty: difficulty, isLoading: true);

    try {
      // Yeni sualları əldə edirik
      List<MathQuestion> newQuestions = await _openAIService.generateQuestions(difficulty);
      // Timer-i yenidən başladırıq
      _startTimer();
      emit(state.copyWith(
        isLoading: false,
        isGameActive: true,
        questions: newQuestions,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load more questions: ${e.toString()}',
      ));
    }
  }

  void _onResetGame(Emitter<GameState> emit, {GameDifficulty? difficulty, bool? isLoading}) {
    _gameTimer?.cancel();
    _questionTimer?.cancel();
    emit(GameState.initial().copyWith(difficulty: difficulty, isLoading: isLoading));
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(GameEvent.timerTick());
    });
  }

  // First, add this new method for handling timer ticks specifically for True/False mode
  void _onTimerTick(Emitter<GameState> emit) {
    if (state.useQuestionTimer && state.difficulty == GameDifficulty.trueFalse) {
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

  void _onEndGame(Emitter<GameState> emit) {
    _gameTimer?.cancel();
    _questionTimer?.cancel();
    emit(state.copyWith(isGameActive: false, showResultDialog: true));
  }

  void _onShowNextQuestion(Emitter<GameState> emit) {
    logger.log("_onShowNextQuestion çağırıldı, amma artıq istifadə olunmur");
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _questionTimer?.cancel();
    _audioService.dispose();
    return super.close();
  }
}
