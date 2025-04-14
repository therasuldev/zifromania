import 'package:equation_quest/presentation/state_managment/game_bloc/game_bloc.dart';
import 'package:equation_quest/presentation/widgets/result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/math_question.dart';
import '../widgets/game/timer_indicator.dart';
import '../widgets/game/score_indicator.dart';
import '../widgets/game/question_container.dart';
import '../widgets/game/answer_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final GameDifficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController buttonAnimationController;

  @override
  void initState() {
    super.initState();

    buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.0,
    );

    // Start the game with the selected difficulty once the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameBloc>().add(GameEvent.startGame(difficulty: widget.difficulty));
    });
  }

  @override
  void dispose() {
    buttonAnimationController.dispose();
    super.dispose();
  }

  void showResultDialog(int score, GameState state) async {
    final buildDialog = ResultDialog(score: score, state: state, onPlayAgain: onPlayAgain);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => buildDialog,
    );
  }

  void onPlayAgain() {
    Navigator.pop(context);

    final event = GameEvent.playAgain(difficulty: widget.difficulty);
    context.read<GameBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<GameBloc, GameState>(
            listener: (context, state) {
              // Show result dialog when game ends
              if (!state.isGameActive && (state.showResultDialog ?? false)) {
                showResultDialog(state.score, state);
              }

              // Show error message if question generation fails
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              // Loading state
              if (state.isLoading) {
                return _buildLoadingState();
              }

              // No questions available
              if (state.questions.isEmpty) {
                return _buildEmptyState();
              }

              // Game active with questions
              final question = state.currentQuestion;
              if (question == null) {
                return _buildEmptyState();
              }

              return _buildGameContent(context, state, question);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lotties/timer.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText(
                  'Creating New Questions...',
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'rimouskisb',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              repeatForever: true,
              pause: const Duration(milliseconds: 100),
              displayFullTextOnTap: true,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please wait',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'rimouskisb',
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lotties/timer.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sual tapılmadı.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, GameState state, MathQuestion question) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TimerIndicator(secondsRemaining: state.secondsRemaining),
              ScoreIndicator(score: state.score),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GameQuestionContainer(question: question.question),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(question.answerOptions.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: AnswerButton(
                  index: index,
                  buttonAnimationController: buttonAnimationController,
                  onTap: () {
                    context.read<GameBloc>().add(
                          GameEvent.checkAnswer(
                            question: state.currentQuestion!,
                            selectedAnswerIndex: index,
                          ),
                        );
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
