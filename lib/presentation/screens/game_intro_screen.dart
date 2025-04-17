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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
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
              DifficultyButton(
                title: 'Speed Calculation',
                icon: 'assets/icons/rocket.png',
                color: Colors.amber, // Vibrant and energetic
                difficulty: GameDifficulty.speedCalculation,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Multiplication Table',
                icon: 'assets/icons/multiplication_table.png',
                color: Colors.indigo, // Strong and academic
                difficulty: GameDifficulty.multiplyDivideBattle,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'True or False',
                icon: 'assets/icons/true_false.png',
                color: Colors.teal, // Balanced and calming
                difficulty: GameDifficulty.trueFalse,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Expert Mode',
                icon: 'assets/icons/expert.png',
                color: Colors.deepOrange, // Bold and challenging
                difficulty: GameDifficulty.expert,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Training Mode',
                icon: 'assets/icons/training.png',
                color: Colors.lightGreen, // Friendly and inviting
                difficulty: GameDifficulty.endless,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
