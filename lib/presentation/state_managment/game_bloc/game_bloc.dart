import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equation_quest/domain/entities/enums.dart';
import 'package:equation_quest/domain/entities/math_question.dart';
import 'package:equation_quest/services/audio_service.dart';
import 'package:equation_quest/services/open_ai_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const int MAX_INCORRECT_ANSWERS = 4;
  final AudioService _audioService = AudioService();
  final OpenAIService _openAIService = OpenAIService.instance;
  Timer? _gameTimer;

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
    // Set initial game state but keep isLoading true until questions are loaded
    emit(GameState.initial().copyWith(
      isLoading: true,
      difficulty: difficulty,
    ));

    try {
      // Generate questions based on selected difficulty
      List<MathQuestion> questions = await _openAIService.generateQuestions(difficulty);

      // Start the timer and update state with questions
      _startTimer();
      emit(state.copyWith(
        isLoading: false,
        questions: questions,
        isGameActive: true,
      ));
    } catch (e) {
      // Handle error case
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load questions: ${e.toString()}',
        isGameActive: false,
      ));
    }
  }

  Future<void> _onCheckAnswer(MathQuestion question, int selectedIndex, Emitter<GameState> emit) async {
    if (!state.isGameActive) return;

    final bool isCorrect = question.answerOptions[selectedIndex] == question.correctAnswer;

    // Cari score və səhv cavab sayını alırıq
    int newScore = state.score;
    int newIncorrect = state.incorrectAnswersCount;

    // Əgər cavab doğrudursa score-u artırırıq, əks halda səhv sayını artırırıq
    if (isCorrect) {
      newScore++;
    } else {
      newIncorrect++;
      if (newIncorrect >= GameBloc.MAX_INCORRECT_ANSWERS) {
        newScore = max(0, newScore - 1);
        newIncorrect = 0;
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
        emit(state.copyWith(
          currentQuestionIndex: nextIndex,
          lastSelectedAnswer: null,
          isLastAnswerCorrect: null,
        ));
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
    emit(GameState.initial().copyWith(difficulty: difficulty, isLoading: isLoading));
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(GameEvent.timerTick());
    });
  }

  void _onTimerTick(Emitter<GameState> emit) {
    if (state.secondsRemaining > 0) {
      emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
    } else {
      add(GameEvent.endGame());
    }
  }

  void _onEndGame(Emitter<GameState> emit) {
    _gameTimer?.cancel();
    emit(state.copyWith(isGameActive: false, showResultDialog: true));
  }

  void _onShowNextQuestion(Emitter<GameState> emit) {
    logger.log("_onShowNextQuestion çağırıldı, amma artıq istifadə olunmur");
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _audioService.dispose();
    return super.close();
  }
}
