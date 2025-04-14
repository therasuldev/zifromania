import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final int score;
  final VoidCallback onPlayAgain;

  const ResultDialog({
    super.key,
    required this.score,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Oyun Bitdi!'),
      content: Text('Sizin nəticəniz: $score doğru cavab!'),
      actions: [
        TextButton(
          child: const Text('Yenidən Oyna'),
          onPressed: () {
            Navigator.of(context).pop();
            onPlayAgain();
          },
        ),
        TextButton(
          child: const Text('Ana Səhifəyə Qayıt'),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
        ),
      ],
    );
  }
}
