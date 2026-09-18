import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/features/game_usage/domain/entities/game_state.dart';
import 'package:zifromania/presentation/widgets/animated_button.dart';

class ResultDialog extends StatelessWidget {
  final int score;
  final VoidCallback onPlayAgain;
  final GameState state;

  const ResultDialog({
    super.key,
    required this.score,
    required this.state,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/scaffold.jpg'),
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
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
                        Icons.emoji_events_rounded,
                        color: Colors.yellow,
                        size: 32,
                      ),
                      Text(
                        context.tr('game.over'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Brawler',
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.pop();
                          context.pop();
                        },
                        child: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/delete.png')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/icons/star.png', width: 40, height: 40),
                      const SizedBox(height: 20),
                      Image.asset('assets/icons/xp.png', width: 40, height: 40),
                      const SizedBox(height: 20),
                      Image.asset('assets/icons/timer.png', width: 40, height: 40),
                      const SizedBox(height: 20),
                      Image.asset('assets/icons/category.png', width: 40, height: 40),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('game.score', args: ['$score']),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          fontFamily: 'Scabber',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('earned_xp', args: ['${state.xpEarned}']),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          fontFamily: 'Scabber',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('game.time', args: ['${60 - state.secondsRemaining}']),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontFamily: 'Scabber',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('game_categories.${state.gameCategory!.toTextWithUnderscores()}'),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                          fontFamily: 'Scabber',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedButton(
                    icon: Image.asset('assets/icons/replay.png', width: 40, height: 40),
                    color: Colors.transparent,
                    onTap: onPlayAgain,
                    fontSize: 18,
                    fontFamily: 'Onacona',
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  AnimatedButton(
                    icon: Image.asset('assets/icons/home.png', width: 40, height: 40),
                    color: Colors.transparent,
                    onTap: () {
                      context.pop();
                      context.pop();
                    },
                    fontSize: 18,
                    fontFamily: 'Onacona',
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
