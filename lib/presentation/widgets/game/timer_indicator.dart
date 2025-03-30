import 'package:flutter/material.dart';

class TimerIndicator extends StatelessWidget {
  final int secondsRemaining;

  const TimerIndicator({super.key, required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: secondsRemaining < 10 ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer, 
            color: secondsRemaining < 10 ? Colors.red.shade700 : Colors.green.shade700
          ),
          const SizedBox(width: 8),
          Text(
            '$secondsRemaining',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: secondsRemaining < 10 ? Colors.red : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}