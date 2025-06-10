import 'package:zifromania/presentation/state-managment/game/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnswerButton extends StatefulWidget {
  final int index;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getButtonColor({
    required dynamic answerValue,
    required String correctAnswer,
    required int index,
    int? lastSelectedAnswer,
    required int currentQuestionIndex,
    required GameState state,
  }) {
    if (lastSelectedAnswer == null || state.lastAnsweredQuestionIndex != currentQuestionIndex) {
      return Colors.transparent;
    }

    // Handle true/false as 1/0
    if (answerValue is String && (answerValue == "True" || answerValue == "False")) {
      final numeric = answerValue == "True" ? "1" : "0";
      if (numeric == correctAnswer) return const Color.fromARGB(50, 50, 255, 153);
      if (lastSelectedAnswer == index) return const Color.fromARGB(50, 255, 50, 50);
    } else {
      if (answerValue == correctAnswer) return const Color.fromARGB(50, 50, 255, 153);
      if (lastSelectedAnswer == index) return const Color.fromARGB(50, 255, 50, 50);
    }

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final question = state.currentQuestion;
        if (question == null || widget.index >= question.answerOptions.length) {
          return const SizedBox.shrink();
        }

        final answerValue = question.answerOptions[widget.index];
        final correctAnswer = question.correctAnswer;

        return GestureDetector(
          onTapDown: (_) => _scaleController.reverse(),
          onTapUp: (_) {
            _scaleController.forward();
            if (state.lastAnsweredQuestionIndex != state.currentQuestionIndex) {
              widget.onTap();
            }
          },
          onTapCancel: () => _scaleController.forward(),
          child: ScaleTransition(
            scale: _scaleController,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getButtonColor(
                  answerValue: answerValue,
                  correctAnswer: correctAnswer,
                  index: widget.index,
                  currentQuestionIndex: state.currentQuestionIndex,
                  state: state,
                  lastSelectedAnswer: state.lastSelectedAnswer,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: state.lastSelectedAnswer != null ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    answerValue.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Scabber',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
