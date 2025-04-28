import 'package:equation_quest/presentation/common/partial_modal_route.dart';
import 'package:equation_quest/presentation/screens/settings_screen.dart';
import 'package:equation_quest/presentation/widgets/animated_icon_button.dart';
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
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
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
                color: Colors.amber,
                difficulty: GameDifficulty.speedCalculation,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Multiplication Table',
                icon: 'assets/icons/multiplication_table.png',
                color: Colors.indigo,
                difficulty: GameDifficulty.multiplyDivideBattle,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'True or False',
                icon: 'assets/icons/true_false.png',
                color: Colors.teal,
                difficulty: GameDifficulty.trueFalse,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Expert Mode',
                icon: 'assets/icons/expert.png',
                color: Colors.deepOrange,
                difficulty: GameDifficulty.expert,
              ),
              const SizedBox(height: 20),
              const DifficultyButton(
                title: 'Training Mode',
                icon: 'assets/icons/training.png',
                color: Colors.lightGreen,
                difficulty: GameDifficulty.endless,
              ),
              // Add spacing to ensure buttons don't overlap with bottom bar
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedIconButton(
        onTap: () {},
        icon: Image.asset('assets/icons/subscription.png'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 70),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedIconButton(
                onTap: () {},
                icon: Image.asset('assets/icons/achievements.png'),
              ),
              AnimatedIconButton(
                onTap: () => Navigator.push(context, PartialModalRoute(child: const SettingsPage())),
                icon: Image.asset('assets/icons/settings.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
