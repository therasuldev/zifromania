import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../../domain/usecases/generate_question.dart';
import '../../domain/entities/math_question.dart';
import '../screens/game_intro_screen.dart';
import '../widgets/game/timer_indicator.dart';
import '../widgets/game/score_indicator.dart';
import '../widgets/game/question_container.dart';
import '../widgets/game/answer_button.dart';
import '../state_managment/game_state.dart';
import '../../services/audio_service.dart';
import '../../services/confetti_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final GameDifficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const int MAX_INCORRECT_ANSWERS = 4;

  late GameState gameState;
  late MathQuestion currentMathQuestion;
  late GenerateQuestionUseCase generateQuestionUseCase;
  late AudioService audioService;
  late ConfettiService confettiService;
  late AnimationController buttonAnimationController;

  @override
  void initState() {
    super.initState();

    audioService = AudioService();
    confettiService = ConfettiService();
    generateQuestionUseCase = GenerateQuestionUseCase();

    buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.0,
    );

    gameState = GameState(
      score: 0,
      secondsRemaining: 60,
      isGameActive: true,
      incorrectAnswersCount: 0,
      lastSelectedAnswer: null,
      isLastAnswerCorrect: null,
    );

    currentMathQuestion = generateQuestionUseCase(difficulty: widget.difficulty);
    startGame();
  }

  @override
  void dispose() {
    gameState.timer?.cancel();
    audioService.dispose();
    confettiService.dispose(); // Use the service's dispose method
    buttonAnimationController.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      gameState = GameState(
        score: 0,
        secondsRemaining: 60,
        isGameActive: true,
        incorrectAnswersCount: 0,
        lastSelectedAnswer: null,
        isLastAnswerCorrect: null,
      );
    });

    currentMathQuestion = generateQuestionUseCase(difficulty: widget.difficulty);
    startTimer();
  }

  void startTimer() {
    gameState.timer?.cancel();
    gameState.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (gameState.secondsRemaining > 0) {
          gameState.secondsRemaining--;
        } else {
          endGame();
        }
      });
    });
  }

  void endGame() {
    gameState.timer?.cancel();
    setState(() => gameState.isGameActive = false);
    showResultDialog();
  }

  void checkAnswer(int selectedAnswerIndex) {
    if (!gameState.isGameActive) return;

    bool isCorrect = currentMathQuestion.answerOptions[selectedAnswerIndex] == currentMathQuestion.correctAnswer;

    setState(() {
      gameState.lastSelectedAnswer = selectedAnswerIndex;
      gameState.isLastAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      setState(() => gameState.score++);
      confettiService.play();
    } else {
      setState(() {
        gameState.incorrectAnswersCount++;
        if (gameState.incorrectAnswersCount >= MAX_INCORRECT_ANSWERS) {
          gameState.score = max(0, gameState.score - 1);
          gameState.incorrectAnswersCount = 0;
        }
      });
    }

    audioService.reset();
    audioService.playSoundEffect(isCorrect);

    // Reset the selected answer and generate new question after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && gameState.isGameActive) {
        setState(() {
          gameState.lastSelectedAnswer = null;
          gameState.isLastAnswerCorrect = null;
          currentMathQuestion = generateQuestionUseCase(difficulty: widget.difficulty);
        });
      }
    });
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitdi!'),
          content: Text('Sizin nəticəniz: ${gameState.score} doğru cavab!'),
          actions: [
            TextButton(
              child: const Text('Yenidən Oyna'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: const Text('Ana Səhifəyə Qayıt'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GameIntroScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/jpg/background4.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Time Indicator
                        TimerIndicator(secondsRemaining: gameState.secondsRemaining),

                        // Score Indicator
                        ScoreIndicator(score: gameState.score),
                      ],
                    ),
                  ),

                  // Question Container
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GameQuestionContainer(question: currentMathQuestion.question),
                    ),
                  ),

                  // Answer Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(currentMathQuestion.answerOptions.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AnswerButton(
                            answerValue: currentMathQuestion.answerOptions[index],
                            correctAnswer: currentMathQuestion.correctAnswer,
                            index: index,
                            lastSelectedAnswer: gameState.lastSelectedAnswer,
                            isLastAnswerCorrect: gameState.isLastAnswerCorrect,
                            buttonAnimationController: buttonAnimationController,
                            onTap: () => checkAnswer(index),
                          ),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),

            // Confetti Animation
            Align(
              alignment: Alignment.center,
              child: confettiService.buildConfettiWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
