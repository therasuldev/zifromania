import 'package:equation_quest/domain/entities/enums.dart';
import 'package:equation_quest/presentation/widgets/animated_button.dart';
import 'package:flutter/material.dart';

class RulesDialog extends StatelessWidget {
  final GameDifficulty difficulty;

  const RulesDialog({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    // Get the appropriate rules based on difficulty
    final List<Map<String, String>> rules = _getRulesForDifficulty(difficulty);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 2, 104, 120),
              Color.fromRGBO(9, 37, 29, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.gamepad_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _getTitleForDifficulty(difficulty),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Onacona',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset('assets/icons/delete.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.map((rule) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(rule['icon']!),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule['text']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'rimouskisb',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            AnimatedButton(
              width: 200,
              icon: Image.asset('assets/icons/play-start.png', width: 40, height: 40),
              color: Colors.tealAccent,
              onTap: () => Navigator.of(context).pop(true),
              fontSize: 18,
              fontFamily: 'Onacona',
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper function to get the title based on difficulty
  String _getTitleForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.speedCalculation:
        return "SPEED CALCULATION";
      case GameDifficulty.multiplyDivideBattle:
        return "MULTIPLICATION TABLE";
      case GameDifficulty.trueFalse:
        return "TRUE OR FALSE";
      case GameDifficulty.expert:
        return "EXPERT MODE";
      case GameDifficulty.endless:
        return "TRAINING MODE";
      default:
        return "RULES";
    }
  }

  // Helper function to get rules based on difficulty
  List<Map<String, String>> _getRulesForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.speedCalculation:
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "Solve as many basic arithmetic problems as possible in 60 seconds. Speed is the key!"
          },
          {
            'icon': 'assets/icons/info.png',
            'text':
                "Questions involve quick addition, subtraction, and simple multiplications. Each correct answer earns 1 point."
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text': "For every 4 incorrect answers, 1 point will be deducted from your score. Answer quickly but accurately!"
          },
        ];

      case GameDifficulty.multiplyDivideBattle:
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "Master multiplication tables in 60 seconds. Focus on multiplication and division problems."
          },
          {
            'icon': 'assets/icons/info.png',
            'text':
                "Questions will test your knowledge of multiplication and division facts from 1×1 to 10×10. Each correct answer is worth 1 point."
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text':
                "A penalty of 1 point will be applied after every 4 wrong answers. Practice daily to improve your multiplication skills!"
          },
        ];

      case GameDifficulty.trueFalse:
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "You'll see mathematical equations and must decide if they are TRUE or FALSE within 60 seconds."
          },
          {
            'icon': 'assets/icons/info.png',
            'text': "Swipe RIGHT for TRUE equations and LEFT for FALSE ones. Each correct judgment earns you 1 point."
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text':
                "Be careful! For every 4 incorrect judgments, 1 point will be deducted. Trust your instincts but verify the math!"
          },
        ];

      case GameDifficulty.expert:
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "Face challenging problems involving multiple operations, powers, and complex calculations within 60 seconds."
          },
          {
            'icon': 'assets/icons/info.png',
            'text':
                "Questions include advanced arithmetic, algebraic expressions, and multi-step problems. Each correct solution earns 2 points."
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text':
                "The penalty for mistakes is higher: 2 points deducted after every 4 wrong answers. This mode is for math enthusiasts seeking a real challenge!"
          },
        ];

      case GameDifficulty.endless:
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "In Training Mode, there's no time limit. Practice at your own pace to improve your math skills."
          },
          {
            'icon': 'assets/icons/info.png',
            'text':
                "Problems increase in difficulty as you progress. Your session continues until you choose to end it, with no score penalties."
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text':
                "This mode tracks accuracy rather than speed. Use it to build confidence and master concepts before trying timed challenges."
          },
        ];

      default:
        // Default rules if needed
        return [
          {
            'icon': 'assets/icons/timer.png',
            'text': "The game will last for 1 minute. During this time, answer as many questions as possible.",
          },
          {
            'icon': 'assets/icons/info.png',
            'text': "After every 4 wrong answers, one point will be deducted from your score.",
          },
          {
            'icon': 'assets/icons/right-arrow-red.png',
            'text':
                "After answering a question, you automatically move to the next question and cannot return to the previous one.",
          },
        ];
    }
  }
}
