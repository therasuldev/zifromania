import 'package:flutter/material.dart';

class TimerIndicator extends StatelessWidget {
  final int secondsRemaining;

  const TimerIndicator({super.key, required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.timer, color: secondsRemaining < 10 ? Colors.red : Colors.green),
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
            '$secondsRemaining',
            key: ValueKey<int>(secondsRemaining),
            style: TextStyle(
              fontFamily: 'Brawler',
              letterSpacing: 2.5,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: secondsRemaining < 10 ? Colors.red : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
