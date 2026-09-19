import 'package:flutter/material.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_state.dart';

class AnswerButton extends StatefulWidget {
  final int index;
  final VoidCallback onTap;
  final GameState state;

  const AnswerButton({
    super.key,
    required this.index,
    required this.onTap,
    required this.state,
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
    required String answerValue,
    required int correctAnswer,
    required int index,
    int? lastSelectedAnswer,
    required int currentQuestionIndex,
    required GameState state,
  }) {
    if (lastSelectedAnswer == null || state.lastAnsweredQuestionIndex != currentQuestionIndex) {
      return Colors.transparent;
    }

    // Check if this is the correct answer
    bool isCorrectAnswer = false;

    // Handle true/false questions
    if (answerValue == "True" || answerValue == "False") {
      final numericValue = answerValue == "True" ? 1 : 0;
      isCorrectAnswer = numericValue == correctAnswer;
    } else {
      // Handle numeric questions
      final numericValue = int.tryParse(answerValue);
      if (numericValue != null) {
        isCorrectAnswer = numericValue == correctAnswer;
      } else {
        // String comparison as fallback
        isCorrectAnswer = answerValue == correctAnswer.toString();
      }
    }

    // Color logic
    if (isCorrectAnswer) {
      return const Color.fromARGB(50, 50, 255, 153);
    }
    if (lastSelectedAnswer == index) {
      return const Color.fromARGB(50, 255, 50, 50);
    }

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final question = state.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    // Get the answer options as a list of keys and values
    final optionKeys = question.answerOptions.keys.toList();
    // Check if the index is valid
    if (widget.index >= optionKeys.length) {
      return const SizedBox.shrink();
    }

    // Get the answer value for this index
    final answerKey = optionKeys[widget.index];
    final answerValue = question.answerOptions[answerKey]!;
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: state.lastSelectedAnswer != null
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Text(
                          answerValue,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Scabber',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Option key (A, B, C, D)
            Positioned(
              left: -10,
              top: -15,
              child: Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                ),
                child: Text(
                  optionKeys[widget.index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Scabber',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
