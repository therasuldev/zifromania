import 'package:flutter/material.dart';

class ScoreIndicator extends StatelessWidget {
  final int score;

  const ScoreIndicator({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow),
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
            key: ValueKey<int>(score), // Ensures the widget updates when the score changes
            style: const TextStyle(
              fontFamily: 'Onacona',
              // letterSpacing: 2.5,
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
