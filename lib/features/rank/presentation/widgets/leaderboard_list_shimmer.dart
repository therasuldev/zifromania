import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder for the rank list (positions 4+) while loading.
class LeaderboardListShimmer extends StatelessWidget {
  const LeaderboardListShimmer({super.key, this.itemCount = 10});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!.withValues(alpha: 0.5),
      highlightColor: Colors.grey[600]!.withValues(alpha: 0.5),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.white10,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) => const _ShimmerListRow(),
      ),
    );
  }
}

class _ShimmerListRow extends StatelessWidget {
  const _ShimmerListRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 16,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}
