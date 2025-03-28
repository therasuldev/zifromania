import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../widgets/difficulty_button.dart';

class GameIntroScreen extends StatefulWidget {
  const GameIntroScreen({super.key});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MATH\nMASTER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  letterSpacing: 5.0,
                  fontFamily: 'Brawler',
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.green.shade900,
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const DifficultyButton(title: 'Easy Mode', color: Colors.pink, difficulty: GameDifficulty.easy),
              const SizedBox(height: 20),
              DifficultyButton(title: 'Medium Mode', color: Colors.orange.shade400, difficulty: GameDifficulty.medium),
              const SizedBox(height: 20),
              const DifficultyButton(title: 'Hard Mode', color: Colors.red, difficulty: GameDifficulty.hard),
              const SizedBox(height: 20),
              const DifficultyButton(title: 'Master Mode', color: Colors.blueGrey, difficulty: GameDifficulty.master),
              const SizedBox(height: 20),
              const DifficultyButton(
                  title: 'Times&Divide Table', color: Colors.lightBlue, difficulty: GameDifficulty.timesDivideTable),
            ],
          ),
        ),
      ),
    );
  }
}
