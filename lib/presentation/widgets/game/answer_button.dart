import 'package:flutter/material.dart';
import '../../common/grid_painter.dart';

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
      return Colors.blue; // Default state
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getButtonColor().withOpacity(0.8),
                    _getButtonColor(),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getButtonColor().withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: GridPainter(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  // Button Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (lastSelectedAnswer == index) const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
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
                  _buildCornerDecoration(top: true, left: true),
                  _buildCornerDecoration(top: true, left: false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCornerDecoration({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      left: left ? 0 : null,
      bottom: top ? null : 0,
      right: left ? null : 0,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(20) : Radius.zero,
            topRight: top && !left ? const Radius.circular(20) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
