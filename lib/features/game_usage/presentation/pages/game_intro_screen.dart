import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/router/route_names.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zifromania/features/user/presentation/providers/user/user_notifier.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/presentation/widgets/coin_display.dart';
import 'package:zifromania/presentation/widgets/game_category_button.dart';
// TODO TEKRARLANMA - STATIC LSIT YARADIB BUILDER ISTIFADE ETMEK OLAR

/* final categories = [
  {
    'title': context.tr('game_categories.quick_thinking'),
    'icon': 'assets/icons/quick.png',
    'color': Colors.amber,
    'category': GameCategory.quickThinking,
  },
]; */

class GameIntroScreen extends ConsumerWidget {
  const GameIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authNotifierProvider).value;
    final userAsync = authUser == null ? null : ref.watch(userProvider(authUser.uid));

    final coins = userAsync?.when(
          data: (user) => user.coins,
          loading: () => authUser?.coins ?? 0,
          error: (_, __) => authUser?.coins ?? 0,
        ) ??
        0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 130,
        leading: CoinDisplay(
          coins: coins,
          onTap: () async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              context.push('${RouteNames.subscription}?tab=coins');
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
              context.push(RouteNames.leaderboard);
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
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('game_categories.quick_thinking'),
                  icon: 'assets/icons/quick.png',
                  color: Colors.amber,
                  category: GameCategory.quickThinking,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('game_categories.multiply_divide'),
                  icon: 'assets/icons/multiplication_table.png',
                  color: Colors.indigo,
                  category: GameCategory.multiplyDivide,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('game_categories.true_or_false'),
                  icon: 'assets/icons/true_false.png',
                  color: Colors.teal,
                  category: GameCategory.trueOrFalse,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('game_categories.expert'),
                  icon: 'assets/icons/expert.png',
                  color: Colors.deepOrange,
                  category: GameCategory.expert,
                ),
                const SizedBox(height: 20),
                GameCategoryButton(
                  title: context.tr('game_categories.training'),
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
        onTap: () => context.push('${RouteNames.subscription}?tab=subscription'),
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
                onTap: () => context.push(RouteNames.achievements),
                icon: SizedBox(
                    height: 64, width: 64, child: Image.asset('assets/icons/achievements.png')),
              ),
              AnimatedIconButton(
                onTap: () => context.push(RouteNames.settings),
                icon: SizedBox(
                    height: 64, width: 64, child: Image.asset('assets/icons/settings.png')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
