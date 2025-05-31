import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/presentation/common/partial_modal_route.dart';
import 'package:zifromania/presentation/screens/achievements.dart';
import 'package:zifromania/presentation/screens/settings_screen.dart';
import 'package:zifromania/presentation/screens/subscription_screen.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';
import '../widgets/game_category_button.dart';
import '../widgets/coin_display.dart';
import 'leaderboard_screen.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: CoinDisplay(
          coins: 350,
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              final route = PartialModalRoute(child: const SubscriptionScreen(tabType: TabType.coins));
              Navigator.push(context, route);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/rank.png',
              height: 56,
              width: 56,
            ),
            onPressed: () {
              Navigator.push(context, PartialModalRoute(child: const LeaderboardScreen()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'ZIFRO\nMANIA',
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
                GameCategoryButton(
                  title: context.tr('quick_thinking'),
                  icon: 'assets/icons/quick.png',
                  color: Colors.amber,
                  category: GameCategory.quickThinking,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('multiply_divide'),
                  icon: 'assets/icons/multiplication_table.png',
                  color: Colors.indigo,
                  category: GameCategory.multiplyDivide,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('true_or_false'),
                  icon: 'assets/icons/true_false.png',
                  color: Colors.teal,
                  category: GameCategory.trueOrFalse,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('expert'),
                  icon: 'assets/icons/expert.png',
                  color: Colors.deepOrange,
                  category: GameCategory.expert,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('training'),
                  icon: 'assets/icons/training.png',
                  color: Colors.lightGreen,
                  category: GameCategory.training,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedIconButton(
        onTap: () => Navigator.push(
          context,
          PartialModalRoute(
            child: const SubscriptionScreen(
              tabType: TabType.subscription,
            ),
          ),
        ),
        icon: SizedBox(height: 64, width: 64, child: Image.asset('assets/icons/subscription.png')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 70),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedIconButton(
                onTap: () => Navigator.push(context, PartialModalRoute(child: const AchievementsScreen())),
                icon: SizedBox(height: 64, width: 64, child: Image.asset('assets/icons/achievements.png')),
              ),
              AnimatedIconButton(
                onTap: () => Navigator.push(context, PartialModalRoute(child: const SettingsScreen())),
                icon: SizedBox(height: 64, width: 64, child: Image.asset('assets/icons/settings.png')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
