import 'package:flutter/material.dart';

class ScoreIndicator extends StatelessWidget {
  final int score;

  const ScoreIndicator({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/icons/star.png', height: 24, width: 24),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            // You can change this transition as desired.
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Text(
            '$score',
            key: ValueKey<int>(score),
            style: const TextStyle(
              fontFamily: 'Scabber',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
        ),
      ],
    );
  }
}
