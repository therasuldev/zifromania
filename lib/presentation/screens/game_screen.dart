import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zifromania/features/game_usage/presentation/providers/game_notifier.dart';
import 'package:zifromania/features/title/data/models/title_model.dart';
import 'package:zifromania/presentation/widgets/dialogs/result_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/subscription_dialog.dart';
import 'package:zifromania/presentation/widgets/dialogs/title_unlock_dialog.dart';
import 'package:zifromania/presentation/widgets/game/answer_button.dart';
import 'package:zifromania/presentation/widgets/game/question_container.dart';
import 'package:zifromania/presentation/widgets/game/score_indicator.dart';
import 'package:zifromania/presentation/widgets/game/timer_indicator.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.gameCategory, this.paidWithCoin = false});

  final GameCategory gameCategory;
  final bool paidWithCoin;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authNotifierProvider).value;
      if (!mounted) return;
      if (user != null) {
        ref.read(gameProvider.notifier).start(user.uid, category: widget.gameCategory, paidWithCoin: widget.paidWithCoin);
      }
    });
  }

  @override
  void dispose() {
    buttonAnimationController.dispose();
    super.dispose();
  }

  void showResultDialog(int score, GameState state) async {
    final buildDialog = ResultDialog(score: score, state: state, onPlayAgain: onPlayAgain);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => buildDialog,
    );
  }

  void showSubscriptionDialog(BuildContext context, String message) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final buildDialog = SubscriptionDialog(
      message: message,
      user: user,
      category: widget.gameCategory,
    );

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => buildDialog,
    );
  }

  void onPlayAgain() async {
    context.pop();

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;
    if (!mounted) return;
    ref.read(gameProvider.notifier).playAgain(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (!next.isGameActive && next.showResultDialog && !(previous?.showResultDialog ?? false)) {
        _handleGameEnd(context, next);
      }
      final error = next.appException;
      if (error == null || error == previous?.appException) return;
      if (error is DailyLimitReachedException || error is InsufficientCoinsException) {
        showSubscriptionDialog(context, error.message);
      } else {
        _showSnackBar(context, error);
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(gameProvider.notifier).cancelCurrentOperation();
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
            child: state.isLoading
                ? _buildLoadingState()
                : state.questions.isEmpty
                    ? _buildEmptyState(appException: state.appException)
                    : state.currentQuestion == null
                        ? _buildEmptyState()
                        : _buildGameContent(context, state, state.currentQuestion!),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, AppException exp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
                      exp.message,
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
                  color: Colors.white.withValues(alpha: 0.2),
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

  // Add this method to your widget class
  void _handleGameEnd(BuildContext context, GameState state) {
    if (state.newlyEarnedTitles.isNotEmpty) {
      _showTitleRewardAnimation(context, state.newlyEarnedTitles, state);
    } else {
      _showResultDialog(context, state);
    }
  }

  void _showTitleRewardAnimation(BuildContext context, List<TitleModel> newTitles, GameState state) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => TitleRewardDialog(
        titles: newTitles,
        onComplete: () {
          context.pop(); // Close title dialog
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

  Widget _buildEmptyState({AppException? appException}) {
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
              _getErrorMessage(appException),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Scabber',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getLottieAssetPath() {
    return 'assets/lotties/timer.json';
  }

  String _getErrorMessage(AppException? exception) {
    if (exception is DailyLimitReachedException) return context.tr('error.daily_limit_reached');
    if (exception is FileLoadException) return context.tr('error.file_load_error');
    if (exception is InvalidJsonException) return context.tr('error.invalid_json');
    if (exception is NetworkException) return context.tr('error.network_error');
    return exception?.message ?? context.tr('game.no_questions');
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
                state: state,
                onTap: () {
                  ref.read(gameProvider.notifier).checkAnswer(0);
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
                state: state,
                onTap: () {
                  ref.read(gameProvider.notifier).checkAnswer(1);
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
                  state: state,
                  onTap: () {
                    ref.read(gameProvider.notifier).checkAnswer(0);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: AnswerButton(
                  index: 1,
                  state: state,
                  onTap: () {
                    ref.read(gameProvider.notifier).checkAnswer(1);
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
                  state: state,
                  onTap: () {
                    ref.read(gameProvider.notifier).checkAnswer(2);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AnswerButton(
                  index: 3,
                  state: state,
                  onTap: () {
                    ref.read(gameProvider.notifier).checkAnswer(3);
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
