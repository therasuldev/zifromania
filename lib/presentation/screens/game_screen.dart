import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:zifromania/app_exception.dart';

import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/presentation/screens/subscription_screen.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/presentation/state-managment/game/game_bloc.dart';
import 'package:zifromania/presentation/widgets/dialogs/result_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/subscription_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/title_unlock_dialog.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/math_question.dart';
import '../widgets/game/answer_button.dart';
import '../widgets/game/question_container.dart';
import '../widgets/game/score_indicator.dart';
import '../widgets/game/timer_indicator.dart';

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

  void showSubscriptionDialog(BuildContext context, String message) async {
    final buildDialog = SubscriptionDialog(message: message);
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
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Geri gedəndə current operasiyanı cancel et
          context.read<GameBloc>().cancelCurrentOperation();
        }
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
                  showSubscriptionDialog(context, context.tr('error.daily_limit_reached'));
                }

                if (state.appException != null) {
                  final error = state.appException!;

                  switch (error.type) {
                    case AppErrorType.dailyLimitReached:
                      showSubscriptionDialog(context, context.tr('error.daily_limit_reached')); // Premium offer dialog
                      break;
                    case AppErrorType.fileLoadError:
                      _showAlertDialog(context, 'File Error', error.message);
                      break;
                    case AppErrorType.invalidJson:
                      _showAlertDialog(context, 'Data Error', 'Question data format is invalid.');
                      break;
                    default:
                      _showSnackBar(context, error.message);
                  }
                }
              },
              builder: (context, state) {
                // Loading state
                if (state.isLoading) {
                  return _buildLoadingState();
                }

                // No questions available
                if (state.questions.isEmpty) {
                  return _buildEmptyState(appErrorType: state.appException?.type);
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

  void _showSnackBar(BuildContext context, String message) {
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
                      message,
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

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
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

  Widget _buildEmptyState({AppErrorType? appErrorType}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              _getLottieAssetPath(),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorMessage(appErrorType),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Scabber',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (appErrorType == AppErrorType.dailyLimitReached) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Subscription sayfasına git
                  const page = SubscriptionScreen(tabType: TabType.subscription);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  context.tr('subscription.upgrade_premium'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Scabber',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getLottieAssetPath() {
    return 'assets/lotties/timer.json';
  }

  String _getErrorMessage(AppErrorType? appErrorType) {
    switch (appErrorType) {
      case AppErrorType.dailyLimitReached:
        return context.tr('error.daily_limit_reached');
      case AppErrorType.networkError:
        return context.tr('error.network_error');
      case AppErrorType.fileLoadError:
        return context.tr('error.file_load_error');
      case AppErrorType.invalidJson:
        return context.tr('error.invalid_json');
      case AppErrorType.unknown:
        return context.tr('error.unknown');
      default:
        return context.tr('game.no_questions');
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GameQuestionContainer(question: question.question),
              ),
              const SizedBox(height: 20), // Aralarında boşluq
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: question.answerOptions.length == 2
                    ? _buildTrueFalseLayout(context, state, question)
                    : _buildMultipleChoiceLayout(context, state, question),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseLayout(BuildContext context, GameState state, MathQuestion question) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // True button - sol tərəfdə yuxarıda
          Positioned(
            top: 20,
            left: 0,
            right: MediaQuery.of(context).size.width * 0.3, // Sağ tərəfi boş saxla
            child: Transform.rotate(
              angle: -0.07, // Yüngül meyillik
              child: AnswerButton(
                index: 0,
                onTap: () {
                  final event = GameEvent.checkAnswer(
                    question: state.currentQuestion!,
                    selectedAnswerIndex: 0,
                  );
                  context.read<GameBloc>().add(event);
                },
              ),
            ),
          ),
          // False button - sağ tərəfdə aşağıda
          Positioned(
            bottom: 20,
            right: 0,
            left: MediaQuery.of(context).size.width * 0.3, // Sol tərəfi boş saxla
            child: Transform.rotate(
              angle: 0.07, // Əks istiqamətdə yüngül meyillik
              child: AnswerButton(
                index: 1,
                onTap: () {
                  final event = GameEvent.checkAnswer(
                    question: state.currentQuestion!,
                    selectedAnswerIndex: 1,
                  );
                  context.read<GameBloc>().add(event);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceLayout(BuildContext context, GameState state, MathQuestion question) {
    return Column(
      children: [
        // Birinci sıra - 2 button
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                child: AnswerButton(
                  index: 0,
                  onTap: () {
                    final event = GameEvent.checkAnswer(
                      question: state.currentQuestion!,
                      selectedAnswerIndex: 0,
                    );
                    context.read<GameBloc>().add(event);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: AnswerButton(
                  index: 1,
                  onTap: () {
                    final event = GameEvent.checkAnswer(
                      question: state.currentQuestion!,
                      selectedAnswerIndex: 1,
                    );
                    context.read<GameBloc>().add(event);
                  },
                ),
              ),
            ),
          ],
        ),
        // İkinci sıra - 2 button
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AnswerButton(
                  index: 2,
                  onTap: () {
                    final event = GameEvent.checkAnswer(
                      question: state.currentQuestion!,
                      selectedAnswerIndex: 2,
                    );
                    context.read<GameBloc>().add(event);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AnswerButton(
                  index: 3,
                  onTap: () {
                    final event = GameEvent.checkAnswer(
                      question: state.currentQuestion!,
                      selectedAnswerIndex: 3,
                    );
                    context.read<GameBloc>().add(event);
                  },
                ),
              ),
            ),
          ],
        ),
        // SizedBox(height: 56),
      ],
    );
  }
}
