import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder for the top-3 podium while data is loading.
class LeaderboardTop3Shimmer extends StatelessWidget {
  const LeaderboardTop3Shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!.withValues(alpha: 0.5),
      highlightColor: Colors.grey[600]!.withValues(alpha: 0.5),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ShimmerPodiumSlot(topPadding: 25, avatarSize: 66, barHeight: 80),
          _ShimmerPodiumSlot(topPadding: 0, avatarSize: 72, barHeight: 100, hasCrown: true),
          _ShimmerPodiumSlot(topPadding: 40, avatarSize: 58, barHeight: 60),
        ],
      ),
    );
  }
}

class _ShimmerPodiumSlot extends StatelessWidget {
  const _ShimmerPodiumSlot({
    required this.topPadding,
    required this.avatarSize,
    required this.barHeight,
    this.hasCrown = false,
  });

  final double topPadding;
  final double avatarSize;
  final double barHeight;
  final bool hasCrown;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: topPadding),
          if (hasCrown) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Container(
            width: 70,
            height: 16,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 12,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: barHeight,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}
