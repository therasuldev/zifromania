import 'package:equation_quest/presentation/state_managment/game_bloc/game_bloc.dart';
import 'package:equation_quest/presentation/widgets/animated_button.dart';
import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final int score;
  final VoidCallback onPlayAgain;
  final GameState state;

  const ResultDialog({
    super.key,
    required this.score,
    required this.state,
    required this.onPlayAgain,
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
              color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.1),
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
                        Icons.emoji_events_rounded,
                        color: Colors.yellow,
                        size: 32,
                      ),
                      Text(
                        "GAME OVER!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Brawler',
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                          ..pop()
                          ..pop(),
                        child: Image.asset('assets/icons/delete.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/icons/star.png', width: 40, height: 40),
                      const SizedBox(height: 20),
                      Image.asset('assets/icons/timer.png', width: 40, height: 40),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Score: $score",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          fontFamily: 'rimouskisb',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Time: ${60 - state.secondsRemaining}s",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontFamily: 'rimouskisb',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedButton(
                    icon: Image.asset('assets/icons/play.png', width: 40, height: 40),
                    color: Colors.tealAccent,
                    onTap: onPlayAgain,
                    fontSize: 18,
                    fontFamily: 'Onacona',
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    borderRadius: 30,
                  ),
                  AnimatedButton(
                    icon: Image.asset('assets/icons/home.png', width: 40, height: 40),
                    color: Colors.tealAccent,
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..pop(),
                    fontSize: 18,
                    fontFamily: 'Onacona',
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    borderRadius: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
