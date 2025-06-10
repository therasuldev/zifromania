import 'package:flutter/material.dart';

class GameQuestionContainer extends StatelessWidget {
  final String question;
  const GameQuestionContainer({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 45,
            // letterSpacing: 2,
            fontFamily: 'Scabber',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
              Shadow(
                color: Colors.black,
                offset: Offset(-3, -3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
