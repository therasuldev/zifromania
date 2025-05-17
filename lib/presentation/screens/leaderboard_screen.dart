import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/services/rank_service.dart';
import 'package:zifromania/services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final RankService _rankService = RankService();
  late Future<List<UserModel>> _topUsersForLevel;
  late Future<int> _userRankPosition;
  late Future<List<UserModel>> _usersAroundCurrent;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.uid ?? '';
    _loadRankData();
  }

  void _loadRankData() {
    _topUsersForLevel = _rankService.fetchTopRankedUsers(limit: 50);
    if (_currentUserId.isNotEmpty) {
      _userRankPosition = _rankService.getUserRankPosition(_currentUserId);
      _usersAroundCurrent = _rankService.getUsersAroundRank(_currentUserId, range: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Leaderboard',
          style: TextStyle(fontFamily: 'Scabber', fontSize: 22, color: lightBrownColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadRankData();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Top 3 Players Section
                    FutureBuilder<List<UserModel>>(
                      future: _topUsersForLevel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildTop3Shimmer();
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Hata: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final users = snapshot.data ?? [];
                        if (users.isEmpty) {
                          return const Center(
                            child: Text(
                              'Henüz oyuncu yok',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Scabber',
                              ),
                            ),
                          );
                        }

                        // Get top 3 users
                        final top3Users = users.length > 3 ? users.sublist(0, 3) : users;

                        return _buildTop3Section(top3Users);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Current User's Rank Section
                    if (_currentUserId.isNotEmpty)
                      Container(
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
                              child: FutureBuilder<int>(
                                future: _userRankPosition,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.brown.shade500.withValues(alpha: .3),
                                      highlightColor: Colors.brown.withValues(alpha: 0.2),
                                      child: Container(
                                        height: 20,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    );
                                  }

                                  return FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Sizin Sıralama: ${snapshot.data ?? 0}',
                                      style: TextStyle(
                                        color: lightBrownColor,
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            PressableFilledButton(
                              onPressed: () {
                                setState(() {
                                  _loadRankData();
                                });
                              },
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
                                  const Text(
                                    'Refresh',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Scabber',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Full Leaderboard
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 45),
                                Expanded(
                                  child: Text(
                                    'Player',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Scabber',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Level',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Scabber',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 36),
                                Text(
                                  'XP',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Scabber',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Colors.white24),
                          FutureBuilder<List<UserModel>>(
                            future: _topUsersForLevel,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildLeaderboardShimmer();
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Hata: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }

                              final users = snapshot.data ?? [];

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
                                  final isCurrentUser = user.uid == _currentUserId;

                                  return _buildRankListItem(
                                    user: user,
                                    position: index + 1,
                                    isCurrentUser: isCurrentUser,
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
      ),
    );
  }

  Widget _buildTop3Shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // First place
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 0),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Third place
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10, // Show 10 shimmer items while loading
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.white10,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: Row(
              children: [
                // Position
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 8),

                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                // Username
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Level
                Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(width: 16),

                // XP
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTop3Section(List<UserModel> top3Users) {
    final List<Widget> podiumItems = [];

    // Fill with empty users if we don't have 3
    while (top3Users.length < 3) {
      top3Users.add(UserModel(
        uid: 'empty${top3Users.length}',
        displayName: 'N/A',
        photoURL: '',
        level: 0,
        xp: 0,
      ));
    }

    // Second Place (Index 1)
    if (top3Users.length > 1) {
      podiumItems.add(
        _buildPodiumUser(
          user: top3Users[1],
          position: 2,
          scale: 0.9,
          topPadding: 25,
        ),
      );
    }

    // First Place (Index 0)
    podiumItems.add(
      _buildPodiumUser(
        user: top3Users[0],
        position: 1,
        scale: 1.0,
        topPadding: 0,
        isWinner: true,
      ),
    );

    // Third Place (Index 2)
    if (top3Users.length > 2) {
      podiumItems.add(
        _buildPodiumUser(
          user: top3Users[2],
          position: 3,
          scale: 0.8,
          topPadding: 40,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: podiumItems,
    );
  }

  Widget _buildPodiumUser({
    required UserModel user,
    required int position,
    required double scale,
    required double topPadding,
    bool isWinner = false,
  }) {
    // Colors for each position
    final Map<int, Color> medalColors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    // Base heights for the podium
    final Map<int, double> podiumHeights = {
      1: 100,
      2: 80,
      3: 60,
    };

    return Expanded(
      child: Column(
        children: [
          SizedBox(height: topPadding),

          // Crown for winner
          if (isWinner) const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),

          const SizedBox(height: 4),

          // Avatar with medal border
          Container(
            padding: EdgeInsets.all(scale * 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: medalColors[position] ?? Colors.grey,
                width: scale * 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (medalColors[position] ?? Colors.grey).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: scale * 30,
              backgroundColor: Colors.white24,
              backgroundImage: (user.photoURL?.isNotEmpty ?? false) ? CachedNetworkImageProvider(user.photoURL!) : null,
              child: user.photoURL?.isEmpty ?? true
                  ? Icon(
                      Icons.person,
                      size: scale * 35,
                      color: Colors.white70,
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 8),

          // Position number
          Container(
            width: scale * 24,
            height: scale * 24,
            decoration: BoxDecoration(
              color: medalColors[position],
              shape: BoxShape.circle,
            ),
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

          // Username
          Text(
            user.displayName ?? 'Player',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Scabber',
              fontWeight: FontWeight.bold,
              fontSize: scale * 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Level
          Text(
            'Level ${user.level}',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Scabber',
              fontSize: scale * 12,
            ),
          ),

          const SizedBox(height: 6),

          // Podium
          Container(
            width: double.infinity,
            height: podiumHeights[position] ?? 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: medalColors[position]?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              border: Border(
                top: BorderSide(
                  color: medalColors[position] ?? Colors.grey,
                  width: 2,
                ),
                left: BorderSide(
                  color: medalColors[position] ?? Colors.grey,
                  width: 1,
                ),
                right: BorderSide(
                  color: medalColors[position] ?? Colors.grey,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankListItem({
    required UserModel user,
    required int position,
    required bool isCurrentUser,
  }) {
    // Colors for top positions
    final Map<int, Color> positionColors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    return Container(
      decoration: BoxDecoration(
        color: positionColors[position]?.withValues(alpha: 0.1) ??
            (isCurrentUser ? Colors.brown.shade200.withValues(alpha: 0.2) : Colors.transparent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 35,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: positionColors[position]?.withValues(alpha: 0.2) ??
                      (isCurrentUser ? Colors.brown.shade200.withValues(alpha: 0.2) : Colors.white10),
                  border: Border.all(
                    color: positionColors[position] ?? (isCurrentUser ? Colors.white : Colors.transparent),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: TextStyle(
                      fontFamily: 'Scabber',
                      color: positionColors[position] ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: (user.photoURL?.isNotEmpty ?? false) ? CachedNetworkImageProvider(user.photoURL!) : null,
              child: (user.photoURL?.isEmpty ?? true)
                  ? const Icon(
                      Icons.person,
                      size: 22,
                      color: Colors.white70,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Username
            Expanded(
              child: Text(
                user.displayName ?? 'Player',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Scabber',
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Level
            Container(
              width: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1),
              ),
              child: Text(
                user.level.toString(),
                style: const TextStyle(
                  fontFamily: 'Scabber',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // XP
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                '${user.xp}',
                style: const TextStyle(
                  fontFamily: 'Scabber',
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
