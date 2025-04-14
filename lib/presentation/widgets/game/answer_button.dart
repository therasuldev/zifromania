import 'package:equation_quest/presentation/state_managment/game_bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnswerButton extends StatelessWidget {
  final int index;
  final AnimationController buttonAnimationController;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.index,
    required this.buttonAnimationController,
    required this.onTap,
  });

  Color _getButtonColor({
    required int answerValue,
    required int correctAnswer,
    required int index,
    int? lastSelectedAnswer,
    bool? isLastAnswerCorrect,
    required int currentQuestionIndex,
    required GameState state, // Bütün state-i alırıq
  }) {
    // Əgər hələ cavab seçilməyibsə
    if (lastSelectedAnswer == null) {
      return Colors.transparent;
    }

    // ƏN VACİB HİSSƏ: Əgər cari sual son cavab verilmiş sual deyilsə, heç bir rəng göstərmə
    if (state.lastAnsweredQuestionIndex != currentQuestionIndex) {
      return Colors.transparent;
    }

    if (answerValue == correctAnswer) {
      return const Color(0xFF1CAC78); // Green
    }

    if (lastSelectedAnswer == index) {
      return const Color(0xFFE32636); // Red
    }

    return const Color.fromARGB(0, 29, 45, 40); // Transparent-ish
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final question = state.currentQuestion;
        if (question == null || index >= question.answerOptions.length) {
          return const SizedBox.shrink();
        }

        final answerValue = question.answerOptions[index];
        final correctAnswer = question.correctAnswer;

        return GestureDetector(
          onTapDown: (_) {
            if (state.lastSelectedAnswer == null) {
              buttonAnimationController.reverse();
            }
          },
          onTapUp: (_) {
            // Son cavab verilmiş sual indiki sualdan fərqlidirsə və ya heç cavab verilməyibsə
            if (state.lastAnsweredQuestionIndex != state.currentQuestionIndex) {
              buttonAnimationController.forward();
              onTap();
            }
          },
          onTapCancel: () {
            buttonAnimationController.animateTo(1.0);
          },
          child: Transform.scale(
            scale: state.lastSelectedAnswer == index ? buttonAnimationController.value : 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: state.lastSelectedAnswer != null
                    ? [
                        BoxShadow(
                          color: _getButtonColor(
                            answerValue: answerValue,
                            correctAnswer: correctAnswer,
                            index: index,
                            lastSelectedAnswer: state.lastSelectedAnswer,
                            isLastAnswerCorrect: state.isLastAnswerCorrect,
                            currentQuestionIndex: state.currentQuestionIndex,
                            state: state,
                          ),
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
                color: state.lastSelectedAnswer != null ? Colors.black.withOpacity(0.5) : Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: state.lastSelectedAnswer != null ? Colors.white.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      answerValue.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Onacona',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
