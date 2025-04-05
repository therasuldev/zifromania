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
        Text(
          '$score',
          style: const TextStyle(
            fontFamily: 'Brawler',
            letterSpacing: 2.5,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
      ],
    );
  }
}
