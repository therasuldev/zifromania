import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/extensions/duration_ext.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/daily_reward/presentation/providers/daily_reward_notifier.dart';
import 'package:zifromania/features/daily_reward/presentation/widgets/animated_reward_widget.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/features/user/presentation/providers/user/user_notifier.dart';

class DailyRewardWidget extends ConsumerWidget {
  const DailyRewardWidget({super.key, this.user});
  final UserModel? user;

  int get _coinsPerClaim => switch (user?.subscription.type) {
        SubscriptionTypeEntity.oneMonth => 15,
        SubscriptionTypeEntity.threeMonths => 20,
        SubscriptionTypeEntity.sixMonths => 30,
        _ => 7,
      };

  Future<void> _claimReward(BuildContext context, WidgetRef ref) async {
    final currentUser = user;
    if (currentUser == null) return;

    final notifier = ref.read(dailyRewardNotifierProvider.notifier);

    // 1. Mükafatı iddia edirik
    await notifier.claimReward();

    // 2. İstifadəçinin coin balansını yeniləyirik (Riverpod Notifier üzərindən)
    await ref.read(userActionsProvider.notifier).addCoins(
          uid: currentUser.uid,
          amount: _coinsPerClaim,
        );

    if (context.mounted) {
      _showRewardClaimedDialog(context, _coinsPerClaim);
    }
  }

  void _showRewardClaimedDialog(BuildContext context, int coins) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reward',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AnimatedRewardWidget(
            animation: animation,
            coins: coins,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardState = ref.watch(dailyRewardNotifierProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBrownColor, Colors.brown.shade300.withValues(alpha: .5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            rewardState.isReady ? 'assets/icons/gift_not_opened.png' : 'assets/icons/gift_opened.png',
            height: 60,
            width: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'coin.daily_reward.title'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Scabber',
                    color: Colors.grey.shade300.withValues(alpha: .7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                rewardState.isReady
                    ? Text(
                        'coin.daily_reward.tap_to_collect'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Scabber',
                          color: Colors.grey.shade400.withValues(alpha: .7),
                        ),
                      )
                    : Text(
                        'coin.daily_reward.come_back_later'.tr(
                          args: [rewardState.remainingTime.toFormattedRewardTime()],
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Scabber',
                          color: Colors.grey.shade400.withValues(alpha: .7),
                        ),
                      ),
              ],
            ),
          ),
          if (rewardState.isReady)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _claimReward(context, ref),
              child: Text(
                'coin.daily_reward.collect_button'.tr(),
                style: const TextStyle(fontFamily: 'Scabber'),
              ),
            )
        ],
      ),
    );
  }
}
