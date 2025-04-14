import 'package:flutter/material.dart';
import '../../../domain/entities/enums.dart';
import '../animated_button.dart';

class RulesDialog extends StatelessWidget {
  final GameDifficulty difficulty;

  const RulesDialog({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 2, 104, 120),
              Color.fromRGBO(9, 37, 29, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.gamepad_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      Text(
                        "RULES",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          // letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Onacona',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset('assets/icons/delete.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/timer.png'),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "The game will last for 1 minute. During this time, answer as many questions as possible.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'rimouskisb',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/info.png'),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "After every 4 wrong answers, one point will be deducted from your score.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'rimouskisb',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/right-arrow.png'),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "After answering a question, you automatically move to the next question and cannot return to the previous one.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'rimouskisb',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AnimatedButton(
                title: "OK",
                color: Colors.tealAccent,
                onTap: () => Navigator.of(context).pop(true),
                fontSize: 18,
                fontFamily: 'Onacona',
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                borderRadius: 30,
                usePerspective: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
