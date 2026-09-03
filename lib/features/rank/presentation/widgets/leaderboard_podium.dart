import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:zifromania/features/user/data/models/subscription_model.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

/// Top-3 podium row, built from the first 3 ranked users.
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({super.key, required this.top3Users});

  final List<UserModel> top3Users;

  // Static const -> created once, not rebuilt on every build() call.
  static const Map<int, Color> _medalColors = {
    1: Color(0xFFFFD700), // Gold
    2: Color(0xFFC0C0C0), // Silver
    3: Color(0xFFCD7F32), // Bronze
  };

  static const Map<int, double> _podiumHeights = {1: 100, 2: 80, 3: 60};

  @override
  Widget build(BuildContext context) {
    final users = List<UserModel>.from(top3Users);
    while (users.length < 3) {
      users.add(
        UserModel(
          uid: 'empty${users.length}',
          displayName: 'N/A',
          photoUrl: '',
          level: 0,
          xp: 0,
          subscription: const SubscriptionModel(),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PodiumUserItem(
          key: ValueKey('podium_${users[1].uid}'),
          user: users[1],
          position: 2,
          scale: 0.9,
          topPadding: 25,
          medalColors: _medalColors,
          podiumHeights: _podiumHeights,
        ),
        PodiumUserItem(
          key: ValueKey('podium_${users[0].uid}'),
          user: users[0],
          position: 1,
          scale: 1.0,
          topPadding: 0,
          isWinner: true,
          medalColors: _medalColors,
          podiumHeights: _podiumHeights,
        ),
        PodiumUserItem(
          key: ValueKey('podium_${users[2].uid}'),
          user: users[2],
          position: 3,
          scale: 0.8,
          topPadding: 40,
          medalColors: _medalColors,
          podiumHeights: _podiumHeights,
        ),
      ],
    );
  }
}

class PodiumUserItem extends StatelessWidget {
  const PodiumUserItem({
    super.key,
    required this.user,
    required this.position,
    required this.scale,
    required this.topPadding,
    required this.medalColors,
    required this.podiumHeights,
    this.isWinner = false,
  });

  final UserModel user;
  final int position;
  final double scale;
  final double topPadding;
  final bool isWinner;
  final Map<int, Color> medalColors;
  final Map<int, double> podiumHeights;

  @override
  Widget build(BuildContext context) {
    final medalColor = medalColors[position] ?? Colors.grey;

    return Expanded(
      child: Column(
        children: [
          SizedBox(height: topPadding),
          if (isWinner) const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(scale * 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: medalColor, width: scale * 3),
              boxShadow: [
                BoxShadow(color: medalColor.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: CircleAvatar(
              radius: scale * 30,
              backgroundColor: Colors.white24,
              backgroundImage: (user.photoUrl?.isNotEmpty ?? false) ? CachedNetworkImageProvider(user.photoUrl!) : null,
              child: (user.photoUrl?.isEmpty ?? true) ? Icon(Icons.person, size: scale * 35, color: Colors.white70) : null,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: scale * 24,
            height: scale * 24,
            decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Scabber',
                  fontWeight: FontWeight.bold,
                  fontSize: scale * 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.displayName ?? 'leaderboard.player'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Scabber',
              fontWeight: FontWeight.bold,
              fontSize: scale * 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'leaderboard.level'.tr(args: ['${user.level}']),
            style: TextStyle(color: Colors.white70, fontFamily: 'Scabber', fontSize: scale * 12),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: podiumHeights[position] ?? 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              border: Border(
                top: BorderSide(color: medalColor, width: 2),
                left: BorderSide(color: medalColor, width: 1),
                right: BorderSide(color: medalColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
