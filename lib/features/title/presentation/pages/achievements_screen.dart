import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:zifromania/shared/constants/app_constants.dart';
import 'package:zifromania/features/title/presentation/providers/all_titles_provider.dart';
import 'package:zifromania/shared/widgets/back_button.dart';

import 'package:zifromania/features/title/domain/entities/title_entity.dart';
import 'package:zifromania/features/title/presentation/widgets/achievement.dart';
import 'package:zifromania/features/title/presentation/widgets/achievement_card.dart';
import 'package:zifromania/features/title/presentation/widgets/achievement_details_sheet.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  final GlobalKey _shareCardKey = GlobalKey();

  // Theme settings
  final Color _textColor = Colors.white;
  final Color _subTextColor = Colors.white70;
  final Color _cardBackgroundColor = Colors.black.withValues(alpha: 0.5);

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

  Color _getTitleColor(String titleKey) {
    return switch (titleKey) {
      "truth-seeker" => Colors.cyan,
      "xp-seeker" => Colors.cyanAccent,
      "expert-challenger" => Colors.deepOrange,
      "quick-thinker" => Colors.lightBlueAccent,
      "speedster" => Colors.teal,
      "marathon-mind" => Colors.blue,
      "no-mistake" => Colors.green,
      "persistent-player" => Colors.indigo,
      "legendary" => Colors.amber,
      "multiplier-player" => Colors.cyan,
      "zifro-premium" => Colors.lime,
      _ => Colors.grey,
    };
  }

  void _showTitleDetails(BuildContext context, TitleEntity title) {
    final achievement = Achievement(
      title: title.name,
      description: context.tr(title.description),
      icon: getTitleIconAsset(title.key),
      color: _getTitleColor(title.key),
      titleKey: title.key,
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    );

    showModalBottomSheet<void>(
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
                  Text(
                    'achievements.title'.tr(),
                    style: TextStyle(
                      color: lightBrownColor,
                      fontSize: 22,
                      fontFamily: 'Scabber',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Titles grid, driven by allTitlesProvider (Riverpod)
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final titlesAsync = ref.watch(allTitlesProvider);

                  return titlesAsync.when(
                    loading: () => Center(child: CircularProgressIndicator(color: lightIndigoColor)),
                    error: (error, stackTrace) => _buildEmptyState(
                      icon: 'assets/icons/empty.png',
                      message: 'achievements.no_titles'.tr(),
                      noButton: true,
                    ),
                    data: (titles) {
                      if (titles.isEmpty) {
                        return _buildEmptyState(
                          icon: 'assets/icons/empty.png',
                          message: 'achievements.no_titles'.tr(),
                          noButton: true,
                        );
                      }

                      // TODO: istifadəçinin qazandığı title-ları göstərmək üçün
                      // userTitlesProvider(userId) ilə müqayisə edib isUnlocked
                      // dəyərini ona görə hesablamaq olar.
                      return _buildTitleGrid(titles);
                    },
                  );
                },
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
    return Column(
      children: [
        const SizedBox(height: 200),
        Image.asset(
          icon,
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: _textColor, fontFamily: 'Scabber')),
        if (subMessage != null) ...[
          const SizedBox(height: 8),
          Text(subMessage, textAlign: TextAlign.center, style: TextStyle(color: _subTextColor, fontFamily: 'Scabber')),
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
    );
  }

  /// Title grid
  Widget _buildTitleGrid(List<TitleEntity> titles) {
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

        final achievement = Achievement(
          title: title.name,
          description: context.tr(title.description),
          icon: getTitleIconAsset(title.key),
          titleKey: title.key,
          color: _getTitleColor(title.key),
          isUnlocked: true,
        );

        return AchievementCard(
          achievement: achievement,
          onTap: () => _showTitleDetails(context, title),
          backgroundColor: backgroundColor,
          textColor: _textColor,
          subTextColor: _subTextColor,
        );
      },
    );
  }
}
