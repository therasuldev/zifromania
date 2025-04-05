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
      return const Color.fromARGB(0, 29, 45, 40); // Default state
    }

    if (answerValue == correctAnswer) {
      return Colors.green.shade300; // Correct answer always green
    }

    if (lastSelectedAnswer == index) {
      return Colors.red.shade300; // Selected wrong answer in red
    }

    return Colors.blue; // Other buttons remain blue
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getButtonColor().withOpacity(.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (lastSelectedAnswer == index) const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        answerValue.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Brawler',
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (lastSelectedAnswer == index) const Spacer(),
                    if (lastSelectedAnswer == index)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLastAnswerCorrect == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ),
              // Corner Decorations
            ),
          );
        },
      ),
    );
  }
}
