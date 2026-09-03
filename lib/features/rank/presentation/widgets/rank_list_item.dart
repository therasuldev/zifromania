import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:zifromania/features/user/data/models/user_model.dart';

/// A single row in the leaderboard list (positions 4+).
///
/// Split into small const-friendly sub-widgets so a change in one part
/// (e.g. avatar image load) doesn't force the whole row to rebuild.
class RankListItem extends StatelessWidget {
  const RankListItem({
    super.key,
    required this.user,
    required this.position,
    required this.isCurrentUser,
  });

  final UserModel user;
  final int position;
  final bool isCurrentUser;

  static const Map<int, Color> _positionColors = {
    1: Color(0xFFFFD700),
    2: Color(0xFFC0C0C0),
    3: Color(0xFFCD7F32),
  };

  static const List<Color> _premiumGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
    Color(0xFFFF6B35),
  ];

  @override
  Widget build(BuildContext context) {
    final isPremium = user.hasActiveSubscription;

    return Container(
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(
                colors: _premiumGradient.map((c) => c.withValues(alpha: 0.15)).toList(),
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: !isPremium
            ? (_positionColors[position]?.withValues(alpha: 0.1) ??
                (isCurrentUser ? Colors.brown.shade200.withValues(alpha: 0.2) : Colors.transparent))
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isPremium ? Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.5) : null,
        boxShadow: isPremium ? [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          children: [
            _PositionBadge(
              position: position,
              isCurrentUser: isCurrentUser,
              isPremium: isPremium,
              positionColors: _positionColors,
            ),
            const SizedBox(width: 8),
            _Avatar(user: user, isPremium: isPremium),
            const SizedBox(width: 12),
            Expanded(child: _NameLabel(user: user, isPremium: isPremium)),
            const SizedBox(width: 8),
            _LevelBadge(level: user.level, isPremium: isPremium),
            const SizedBox(width: 16),
            _XpLabel(xp: user.xp, isPremium: isPremium),
          ],
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.position,
    required this.isCurrentUser,
    required this.isPremium,
    required this.positionColors,
  });

  final int position;
  final bool isCurrentUser;
  final bool isPremium;
  final Map<int, Color> positionColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      child: Stack(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !isPremium
                  ? (positionColors[position]?.withValues(alpha: 0.2) ??
                      (isCurrentUser ? Colors.brown.shade200.withValues(alpha: 0.2) : Colors.white10))
                  : null,
              border: Border.all(
                color: isPremium ? const Color(0xFFFFD700) : (positionColors[position] ?? (isCurrentUser ? Colors.white : Colors.transparent)),
                width: isPremium ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  fontFamily: 'Scabber',
                  color: isPremium ? Colors.white : (positionColors[position] ?? Colors.white),
                  fontWeight: FontWeight.bold,
                  fontSize: isPremium ? 14 : 12,
                ),
              ),
            ),
          ),
          if (isPremium)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                child: const Icon(Icons.star, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.isPremium});

  final UserModel user;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: isPremium
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                )
              : null,
          padding: isPremium ? const EdgeInsets.all(2) : EdgeInsets.zero,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white10,
            backgroundImage: (user.photoUrl?.isNotEmpty ?? false) ? CachedNetworkImageProvider(user.photoUrl!) : null,
            child: (user.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, size: 22, color: Colors.white70) : null,
          ),
        ),
        if (isPremium)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Icon(Icons.diamond, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _NameLabel extends StatelessWidget {
  const _NameLabel({required this.user, required this.isPremium});

  final UserModel user;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            user.displayName ?? 'leaderboard.player'.tr(),
            style: TextStyle(
              color: isPremium ? const Color(0xFFFFD700) : Colors.white,
              fontFamily: 'Scabber',
              fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
              fontSize: isPremium ? 16 : 14,
              shadows: isPremium ? [Shadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), offset: const Offset(0, 1), blurRadius: 2)] : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPremium) ...[
          const SizedBox(width: 6),
          const Icon(Icons.workspace_premium, size: 16, color: Color(0xFFFFD700)),
        ],
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.isPremium});

  final int level;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(colors: [
                const Color(0xFFFFD700).withValues(alpha: 0.3),
                const Color(0xFFFFA500).withValues(alpha: 0.3),
              ])
            : null,
        color: !isPremium ? Colors.teal.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPremium ? const Color(0xFFFFD700).withValues(alpha: 0.6) : Colors.teal.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        level.toString(),
        style: TextStyle(
          fontFamily: 'Scabber',
          color: isPremium ? const Color(0xFFFFD700) : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isPremium ? 13 : 12,
        ),
      ),
    );
  }
}

class _XpLabel extends StatelessWidget {
  const _XpLabel({required this.xp, required this.isPremium});

  final int xp;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      alignment: Alignment.centerRight,
      child: Text(
        '$xp',
        style: TextStyle(
          fontFamily: 'Scabber',
          color: isPremium ? const Color(0xFFFFD700) : Colors.white70,
          fontSize: isPremium ? 14 : 13,
          fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
