import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/presentation/state-managment/game/game_bloc.dart';
import 'package:zifromania/presentation/widgets/dialogs/result_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/subscription_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/title_unlock_dialog.dart';
import 'package:zifromania/services/open_ai_service.dart';
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
  const GameScreen({super.key, required this.gameCategory});

  final GameCategory gameCategory;

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

    // Start the game with the selected category once the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameBloc>().add(GameEvent.startGame(gameCategory: widget.gameCategory));
    });
  }

  @override
  void dispose() {
    // Cancel any ongoing request
    locator.get<EnhancedOpenAIService>().cancel();
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

  void showSubscriptionDialog(BuildContext context) async {
    const buildDialog = SubscriptionDialog();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => buildDialog,
    );
  }

  void onPlayAgain() {
    Navigator.pop(context);

    final event = GameEvent.playAgain(gameCategory: widget.gameCategory);
    context.read<GameBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (q, result) {
        // Cancel request when back button is pressed
        locator.get<EnhancedOpenAIService>().cancel();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/scaffold.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black45,
                BlendMode.darken,
              ),
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<GameBloc, GameState>(
              listener: (context, state) {
                // Show result dialog when game ends
                if (!state.isGameActive && (state.showResultDialog ?? false)) {
                  _handleGameEnd(context, state);
                }

                // Show subscription dialog
                if (state.showSubscribeDialog) {
                  showSubscriptionDialog(context);
                }

                // Show error message if question generation fails
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.calculate_outlined,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🔢 Math Challenge',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontFamily: 'Scabber',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      fontFamily: 'Scabber',
                                      color: Colors.white,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                },
                                constraints: const BoxConstraints(
                                  minWidth: 36.0,
                                  minHeight: 36.0,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: const Color(0xFF6366F1), // İndigo rengi
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.all(16.0),
                      elevation: 8.0,
                      duration: const Duration(seconds: 4),
                    ),
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
      ),
    );
  }

  // Add this method to your widget class
  void _handleGameEnd(BuildContext context, GameState state) {
    // Always show ad first
    AdManager().showAdAfterGame(
      onAdClosed: () {
        if (!context.mounted) return;

        // After ad closes, check if we have titles to show
        if (state.newlyEarnedTitles.isNotEmpty) {
          _showTitleRewardAnimation(context, state.newlyEarnedTitles, state);
        } else {
          // No titles, go directly to result dialog
          _showResultDialog(context, state);
        }
      },
    );
  }

  void _showTitleRewardAnimation(BuildContext context, List<TitleModel> newTitles, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => TitleRewardDialog(
        titles: newTitles,
        onComplete: () {
          Navigator.of(context).pop(); // Close title dialog
          _showResultDialog(context, state); // Show result dialog last
        },
      ),
    );
  }

  void _showResultDialog(BuildContext context, GameState state) {
    showResultDialog(state.score, state);
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
                  context.tr('game.loading'),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Scabber',
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
          Text(
            context.tr('game.loading_description'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Scabber',
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
          Text(
            context.tr('game.no_questions'),
            textAlign: TextAlign.center,
            style: const TextStyle(
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
        if (state.gameCategory != GameCategory.training)
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
        if (state.gameCategory == GameCategory.training)
          Text(
            "${state.currentQuestionIndex + 1}/${state.questions.length}",
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontFamily: 'Scabber',
              fontWeight: FontWeight.bold,
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
                  onTap: () {
                    final event = GameEvent.checkAnswer(
                      question: state.currentQuestion!,
                      selectedAnswerIndex: index,
                    );
                    context.read<GameBloc>().add(event);
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
