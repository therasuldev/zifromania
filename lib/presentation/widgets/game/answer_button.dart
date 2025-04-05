import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final int answerValue;
  final int correctAnswer;
  final int index;
  final int? lastSelectedAnswer;
  final bool? isLastAnswerCorrect;
  final AnimationController buttonAnimationController;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.answerValue,
    required this.correctAnswer,
    required this.index,
    required this.lastSelectedAnswer,
    required this.isLastAnswerCorrect,
    required this.buttonAnimationController,
    required this.onTap,
  });

  Color _getButtonColor() {
    if (lastSelectedAnswer == null) {
      return Colors.transparent; // Default state
    }

    if (answerValue == correctAnswer) {
      return const Color(0xFF1CAC78); // Correct answer always green
    }

    if (lastSelectedAnswer == index) {
      return const Color(0xFFE32636); // Selected wrong answer in red
    }

    return const Color.fromARGB(0, 29, 45, 40); // Other buttons remain blue
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (lastSelectedAnswer == null) {
          buttonAnimationController.reverse();
        }
      },
      onTapUp: (_) {
        if (lastSelectedAnswer == null) {
          buttonAnimationController.forward();
          onTap();
        }
      },
      onTapCancel: () {
        buttonAnimationController.animateTo(1.0);
      },
      child: AnimatedBuilder(
        animation: buttonAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: lastSelectedAnswer == index ? buttonAnimationController.value : 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: lastSelectedAnswer != null
                    ? [
                        BoxShadow(
                          color: _getButtonColor(),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
                color: lastSelectedAnswer != null ? Colors.black.withOpacity(0.5) : Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: lastSelectedAnswer != null ? Colors.white.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      answerValue.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Brawler',
                        letterSpacing: 2,
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
      ),
    );
  }
}
