import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/models/task_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state-managment/tasks-bloc/task_bloc.dart';
import 'package:zifromania/presentation/state-managment/titles-bloc/title_bloc.dart';

String getTitleIconAsset(String titleKey) {
  return "assets/title-avatars/$titleKey.png";
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _shareCardKey = GlobalKey();

  // Theme settings
  final Color _textColor = Colors.white;
  final Color _subTextColor = Colors.white70;
  final Color _cardBackgroundColor = Colors.black.withValues(alpha: 0.5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to capture widget as image
  Future<ByteData?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      return null;
    }
  }

  // Save and share the achievement image
  Future<void> _shareAchievement(String title) async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final ByteData? byteData = await _capturePng();

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final File file = await File('${tempDir.path}/achievement.png').create();
        await file.writeAsBytes(pngBytes);

        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: 'achievements.share.share_text'.tr(args: [title]),
          subject: 'achievements.share.share_subtext'.tr(),
        ));
      }
    });
  }

  void _showTitleDetails(BuildContext context, TitleModel title, bool isUnlocked) {
    final achievement = Achievement(
      title: title.name,
      description: title.description,
      icon: getTitleIconAsset(title.key),
      color: Colors.purple, // TODO: DEYISECEK
      titleKey: title.key,
      isUnlocked: isUnlocked,
      unlockedDate: isUnlocked ? DateTime.now() : null,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailsSheet(
        achievement: achievement,
        onShare: () => _shareAchievement(title.name),
        shareCardKey: _shareCardKey,
        backgroundColor: backgroundColor,
        cardBackgroundColor: _cardBackgroundColor,
        textColor: _textColor,
        subTextColor: _subTextColor,
      ),
    );
  }

  void _showTaskDetails(BuildContext context, TaskModel task, bool isCompleted) {
    final achievement = Achievement(
      title: task.title,
      description: task.description,
      icon: task.iconUrl,
      color: Colors.blue,
      titleKey: null,
      isUnlocked: isCompleted,
      score: '${task.xpReward}XP',
      unlockedDate: isCompleted ? DateTime.now() : null,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailsSheet(
        achievement: achievement,
        onShare: () => _shareAchievement(task.title),
        shareCardKey: _shareCardKey,
        backgroundColor: backgroundColor,
        cardBackgroundColor: _cardBackgroundColor,
        textColor: _textColor,
        subTextColor: _subTextColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // App Bar area (back button + title)
            Padding(
              padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  CustomBackButton(color: lightBrownColor),
                  const SizedBox(width: 12),
                  Text('achievements.title'.tr(),
                      style: TextStyle(
                        color: lightBrownColor,
                        fontSize: 22,
                        fontFamily: 'Scabber',
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: lightIndigoColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C87FF).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                unselectedLabelColor: _textColor.withValues(alpha: 0.5),
                labelColor: Colors.white,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontSize: 16, fontFamily: 'Scabber'),
                tabs: [
                  Tab(text: 'achievements.titles'.tr()),
                  Tab(text: 'achievements.tasks'.tr()),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TITLES TAB
                  BlocBuilder<TitleBloc, TitleState>(
                    builder: (context, state) {
                      if (state.event == TitleEvents.fetchAllTitlesStart) {
                        return Center(child: CircularProgressIndicator(color: lightIndigoColor));
                      }
                      if (state.titles.isEmpty) {
                        return _buildEmptyState(
                          icon: 'assets/icons/empty.png',
                          message: 'achievements.no_titles'.tr(),
                          noButton: true,
                        );
                      }

                      // Get current user's earned titles (would need to be fetched from user model)
                      // final user = context.read<UserModel>(); // This would need to be provided in a real app
                      final earnedTitles = context.select((AuthBloc bloc) => bloc.state.user?.achievements ?? []);
                      return _buildTitleGrid(state.titles, earnedTitles);
                    },
                  ),

                  // TASKS TAB
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      if (state.event == TaskEvents.fetchAllTasksStart) {
                        return Center(child: CircularProgressIndicator(color: lightIndigoColor));
                      }
                      if (state.tasks.isEmpty) {
                        return _buildEmptyState(
                          icon: 'assets/icons/empty.png',
                          message: 'achievements.no_tasks'.tr(),
                          noButton: true,
                        );
                      }

                      // Get current user's completed tasks (would need to be fetched from user model)
                      final completedTasks = context.select((AuthBloc bloc) => bloc.state.user?.completedTasks ?? []);

                      return _buildTaskGrid(state.tasks, completedTasks);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState({
    required String icon,
    required String message,
    String? subMessage,
    String? buttonText,
    VoidCallback? onButton,
    bool noButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: 100,
            height: 100,
            //color: noButton ? Colors.amber : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: _textColor, fontFamily: 'Scabber')),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(subMessage, style: TextStyle(color: _subTextColor, fontFamily: 'Scabber')),
          ],
          if (buttonText != null && onButton != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C87FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText, style: const TextStyle(fontFamily: 'Scabber')),
            ),
          ],
        ],
      ),
    );
  }

  /// Title grid
  Widget _buildTitleGrid(List<TitleModel> titles, List<String> earnedTitles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: titles.length,
      itemBuilder: (context, i) {
        final title = titles[i];
        final isUnlocked = earnedTitles.contains(title.id);

        final achievement = Achievement(
          title: title.name,
          description: title.description,
          icon: title.iconUrl,
          titleKey: title.key,
          color: Colors.purple,
          isUnlocked: isUnlocked,
        );

        return AchievementCard(
          achievement: achievement,
          onTap: () => _showTitleDetails(context, title, isUnlocked),
          backgroundColor: backgroundColor,
          textColor: _textColor,
          subTextColor: _subTextColor,
        );
      },
    );
  }

  /// Task grid
  Widget _buildTaskGrid(List<TaskModel> tasks, List<String> completedTasks) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        final isCompleted = completedTasks.contains(task.id);

        final achievement = Achievement(
          title: task.title,
          description: task.description,
          icon: task.iconUrl,
          titleKey: null,
          color: Colors.blue,
          isUnlocked: isCompleted,
          score: '${task.xpReward}XP',
        );

        return AchievementCard(
          achievement: achievement,
          onTap: () => _showTaskDetails(context, task, isCompleted),
          backgroundColor: backgroundColor,
          textColor: _textColor,
          subTextColor: _subTextColor,
        );
      },
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final bool isUnlocked;
  final String? score;
  final String? titleKey;
  final DateTime? unlockedDate;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.isUnlocked,
    this.score,
    this.unlockedDate,
  });
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color subTextColor;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: achievement.isUnlocked ? Border.all(color: achievement.color.withValues(alpha: 0.5), width: 2) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background pattern
            if (achievement.isUnlocked)
              Positioned(
                right: -30,
                top: -30,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: achievement.color.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),

            // Achievement content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Achievement icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                        achievement.isUnlocked
                            ? ClipOval(
                                child: Image.asset(
                                  getTitleIconAsset(achievement.titleKey!),
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : Icon(
                                Icons.lock,
                                size: 32,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                        if (achievement.isUnlocked && achievement.score != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: achievement.color,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: achievement.color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                achievement.score!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Scabber',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Achievement title
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Scabber',
                        color: achievement.isUnlocked ? achievement.color : Colors.grey.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        achievement.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Scabber',
                          color: subTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Earned/Locked label
                    if (achievement.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              achievement.color.withValues(alpha: 0.8),
                              achievement.color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: achievement.color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'achievements.earned'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Scabber',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'achievements.locked'.tr(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontFamily: 'Scabber',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onShare;
  final GlobalKey shareCardKey;
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subTextColor;

  const AchievementDetailsSheet({
    super.key,
    required this.achievement,
    required this.onShare,
    required this.shareCardKey,
    required this.backgroundColor,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/scaffold.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pull indicator
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Shareable card (for screenshot)
          RepaintBoundary(
            key: shareCardKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cardBackgroundColor,
                    achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : cardBackgroundColor,
                  ],
                ),
                border: Border.all(color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.5) : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy/Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo effect
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon container
                      achievement.isUnlocked
                          ? ClipOval(
                              child: Image.asset(
                                achievement.icon,
                                width: 80,
                                height: 80,
                              ),
                            )
                          : Icon(
                              Icons.lock,
                              size: 48,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),

                      if (achievement.isUnlocked && achievement.score != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: achievement.color,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: achievement.color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              achievement.score!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Scabber',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Scabber',
                      color: achievement.isUnlocked ? achievement.color : Colors.grey.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Scabber',
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Earned/Locked badge
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            achievement.color.withValues(alpha: 0.8),
                            achievement.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: achievement.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'achievements.earned'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'achievements.locked'.tr(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Earned date (only for unlocked achievements)
                  if (achievement.isUnlocked && achievement.unlockedDate != null)
                    Text(
                      'achievements.earned_date'.tr(
                        args: ['${achievement.unlockedDate!.day}/${achievement.unlockedDate!.month}/${achievement.unlockedDate!.year}'],
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Scabber',
                        color: subTextColor,
                      ),
                    ),

                  // Game logo
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/zifromania.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ZifroMania',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Scabber',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Paylaşım butonu (sadece kazanılan başarılar için)
          if (achievement.isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: achievement.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.share),
                  label: Text(
                    'achievements.share.title'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Scabber',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'achievements.close'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Scabber',
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu başarıyı kazanmak için oyuna devam edin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Scabber',
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
