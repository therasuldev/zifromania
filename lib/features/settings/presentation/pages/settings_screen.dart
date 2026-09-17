import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/router/route_names.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_action_notifier.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zifromania/features/settings/presentation/providers/language_notifier.dart';
import 'package:zifromania/features/settings/presentation/providers/music_notifier.dart';
import 'package:zifromania/features/settings/presentation/providers/sound_notifier.dart';
import 'package:zifromania/features/settings/presentation/providers/vibration_notifier.dart';
import 'package:zifromania/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:zifromania/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/presentation/providers/user/user_notifier.dart';
import 'package:zifromania/presentation/common/back_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey languageButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildBody(authState.value?.uid, context),
    );
  }

  Widget _buildBody(String? uid, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          image: AssetImage('assets/images/scaffold.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (uid != null) _buildUserProfileSection(uid),
                const SizedBox(height: 24),
                _buildSoundAndFeedbackSection(context),
                const SizedBox(height: 24),
                _buildAboutSection(context),
                const SizedBox(height: 24),
                _buildAccountAppSection(context),
                _buildFooter(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CustomBackButton(color: lightBrownColor),
          const SizedBox(width: 16),
          Text(
            context.tr('settings'),
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 22,
              color: lightBrownColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(String uid) {
    final userAsync = ref.watch(userProvider(uid));

    return userAsync.when(
      data: (user) {
        final int userLevel = user.level;
        final int userXP = user.xp;
        final int xpForNextLevel = user.xpForNextLevel;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserAvatarAndInfo(user, userLevel),
              const SizedBox(height: 16),
              _buildLevelProgressSection(userXP, xpForNextLevel),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => const SizedBox(),
    );
  }

  Widget _buildUserAvatarAndInfo(UserEntity user, int userLevel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with level badge
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.indigoAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.indigoAccent.shade100.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue.shade200,
              backgroundImage: switch (user.photoURL) {
                null => null,
                _ => NetworkImage(user.photoURL!),
              },
              child: switch (user.photoURL) {
                null => Text(
                    user.displayName != null && user.displayName!.isNotEmpty ? user.displayName![0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                _ => null,
              }),
        ),
        const SizedBox(width: 16),

        // User info and coins
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'Player',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Scabber',
                  fontWeight: FontWeight.bold,
                  color: transparentIndigoColor,
                ),
              ),
              Text(
                user.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Scabber',
                  color: Colors.indigo.shade50.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            'Lv. $userLevel',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Scabber',
              fontWeight: FontWeight.bold,
              color: softRedColor.withValues(alpha: 0.7),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLevelProgressSection(int userXP, int xpForNextLevel) {
    final progressPercentage = userXP / xpForNextLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('level_progress'),
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Scabber',
                color: transparentIndigoColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.tr('xp', args: [userXP.toString(), xpForNextLevel.toString()]),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Scabber',
                color: softRedColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Custom level progress bar
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [softIndigoColor, indigoColor],
                    ),
                  ),
                ),
              ),
              // Level markers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
                    height: 20,
                    width: 2,
                    color: index != 0 && index != 4 ? Colors.white24 : Colors.transparent,
                  ),
                ),
              ),
              // Level percentage
              Center(
                child: Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black45,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundAndFeedbackSection(BuildContext context) {
    final soundEnabled = ref.watch(soundNotifierProvider);
    final musicEnabled = ref.watch(musicNotifierProvider);
    final vibrationEnabled = ref.watch(vibrationNotifierProvider);

    return Column(
      children: [
        SettingsSectionTitle(title: context.tr('sound_and_feedback')),
        SettingsTile(
          leading: Image.asset('assets/icons/volume.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('sound_effects'),
          trailing: Switch.adaptive(
            value: soundEnabled,
            activeTrackColor: Colors.green.shade400,
            onChanged: (value) {
              ref.read(soundNotifierProvider.notifier).setSoundEnabled(value);
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/music.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('background_music'),
          trailing: Switch.adaptive(
            value: musicEnabled,
            activeTrackColor: Colors.green.shade400,
            onChanged: (value) {
              ref.read(musicNotifierProvider.notifier).setMusicEnabled(value);
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/vibrate.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('vibration'),
          trailing: Switch.adaptive(
            value: vibrationEnabled,
            activeTrackColor: Colors.green.shade400,
            onChanged: (value) {
              ref.read(vibrationNotifierProvider.notifier).setVibrationEnabled(value);
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/feedback.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('send_feedback'),
          onTap: () {
            context.push(RouteNames.feedback);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        SettingsSectionTitle(title: context.tr('about')),
        SettingsTile(
          leading: Image.asset('assets/icons/information.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('about_zifromania'),
          onTap: () {
            context.push(RouteNames.about);
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/privacy.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('privacy_policy'),
          onTap: () {
            context.push(RouteNames.privacy);
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/service.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('terms_of_service'),
          onTap: () {
            context.push(RouteNames.terms);
          },
        ),
      ],
    );
  }

  Widget _buildAccountAppSection(BuildContext context) {
    final language = ref.watch(languageNotifierProvider);

    return Column(
      children: [
        SettingsSectionTitle(title: context.tr('account_and_app')),
        SettingsTile(
          leading: Image.asset('assets/icons/language.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('languages'),
          trailing: IconButton(
            key: languageButtonKey,
            icon: switch (language) {
              'tr' => const Text('🇹🇷', style: TextStyle(fontSize: 20)),
              'en' || _ => const Text('🇺🇸', style: TextStyle(fontSize: 20)),
            },
            onPressed: () => _showLanguageMenu(context, languageButtonKey),
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/logout.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('logout'),
          onTap: () async {
            await ref.read(authActionNotifierProvider.notifier).signOut();
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/quit.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('quit'),
          onTap: () async {
            await SystemNavigator.pop();
          },
        ),
      ],
    );
  }

  void _showLanguageMenu(BuildContext context, GlobalKey buttonKey) async {
    final RenderBox renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 100,
        offset.dy + size.height,
        offset.dx + 50,
        offset.dy + size.height + 200,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(context.tr('langs.en'), style: const TextStyle(fontFamily: 'Scabber', fontSize: 16)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'tr',
          child: Row(
            children: [
              const Text('🇹🇷', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(context.tr('langs.tr'), style: const TextStyle(fontFamily: 'Scabber', fontSize: 16)),
            ],
          ),
        ),
      ],
    ).then((selectedLanguage) async {
      if (selectedLanguage != null) {
        if (!context.mounted) return;
        context.setLocale(Locale(selectedLanguage));
        await ref.read(languageNotifierProvider.notifier).setLanguage(selectedLanguage);
      }
    });
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        context.tr('version', args: ['1.0.0']),
        style: TextStyle(
          fontFamily: 'Scabber',
          color: lightBrownColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
