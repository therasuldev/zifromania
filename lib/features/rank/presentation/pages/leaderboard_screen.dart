import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:zifromania/core/providers/firebase_provider.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/features/rank/presentation/providers/rank_providers.dart';
import 'package:zifromania/features/rank/presentation/widgets/leaderboard_list_shimmer.dart';
import 'package:zifromania/features/rank/presentation/widgets/leaderboard_podium.dart';
import 'package:zifromania/features/rank/presentation/widgets/leaderboard_top3_shimmer.dart';
import 'package:zifromania/features/rank/presentation/widgets/rank_list_item.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).currentUser?.uid ?? '';
    final topUsersAsync = ref.watch(topRankedUsersProvider);
    final userRankAsync = currentUserId.isNotEmpty ? ref.watch(userRankPositionProvider(currentUserId)) : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'leaderboard.title'.tr(),
          style: TextStyle(fontFamily: 'Scabber', fontSize: 22, color: lightBrownColor),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top 3 Players Section
                  topUsersAsync.when(
                    loading: () => const LeaderboardTop3Shimmer(),
                    error: (error, _) => Center(
                      child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                    data: (users) {
                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            'leaderboard.no_players'.tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Scabber'),
                          ),
                        );
                      }
                      final top3Users = users.length > 3 ? users.sublist(0, 3) : users;
                      return LeaderboardPodium(top3Users: top3Users);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Current User's Rank Section
                  if (currentUserId.isNotEmpty)
                    _CurrentUserRankBar(
                      userRankAsync: userRankAsync!,
                      onRefresh: () {
                        ref.invalidate(topRankedUsersProvider);
                        ref.invalidate(userRankPositionProvider(currentUserId));
                      },
                    ),

                  const SizedBox(height: 24),

                  // Full Leaderboard
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        const _LeaderboardListHeader(),
                        const Divider(height: 1, color: Colors.white24),
                        topUsersAsync.when(
                          loading: () => const LeaderboardListShimmer(),
                          error: (error, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                          data: (allUsers) {
                            final users = allUsers.length > 3 ? allUsers.sublist(3) : <UserModel>[];
                            return ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: users.length,
                              separatorBuilder: (context, index) => const Divider(
                                height: 1,
                                color: Colors.white10,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return RankListItem(
                                  key: ValueKey('rank_${user.uid}'),
                                  user: user,
                                  position: index + 4,
                                  isCurrentUser: user.uid == currentUserId,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardListHeader extends StatelessWidget {
  const _LeaderboardListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const SizedBox(width: 45),
          Expanded(
            child: Text(
              'leaderboard.player'.tr(),
              style: const TextStyle(color: Colors.white70, fontFamily: 'Scabber', fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'leaderboard.level'.tr(args: ['']),
            style: const TextStyle(color: Colors.white70, fontFamily: 'Scabber', fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 36),
          const Text(
            'XP',
            style: TextStyle(color: Colors.white70, fontFamily: 'Scabber', fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _CurrentUserRankBar extends StatelessWidget {
  const _CurrentUserRankBar({required this.userRankAsync, required this.onRefresh});

  final AsyncValue<int> userRankAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade500.withValues(alpha: .5), width: 2),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/star.png', height: 32, width: 32),
          const SizedBox(width: 12),
          Expanded(
            child: userRankAsync.when(
              loading: () => Shimmer.fromColors(
                baseColor: Colors.brown.shade500.withValues(alpha: .3),
                highlightColor: Colors.brown.withValues(alpha: 0.2),
                child: Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              error: (error, _) => Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              data: (rank) => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'leaderboard.your_rank'.tr(args: ['$rank']),
                  style: TextStyle(
                    color: lightBrownColor,
                    fontFamily: 'Scabber',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PressableFilledButton(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade300.withValues(alpha: .2),
              foregroundColor: Colors.white70,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/refresh.png', height: 20, width: 20),
                const SizedBox(width: 8),
                Text(
                  'leaderboard.refresh'.tr(),
                  style: const TextStyle(color: Colors.white70, fontFamily: 'Scabber', fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
