import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/common/partial_modal_route.dart';
import 'package:zifromania/presentation/screens/about_zifromania.dart';
import 'package:zifromania/presentation/screens/privacy_policy.dart';
import 'package:zifromania/presentation/screens/terms_of_service.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_event.dart';
import 'package:zifromania/presentation/state-managment/settings/settings_bloc.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/sound_service.dart';

import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();
  final GlobalKey languageButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: _buildBody(settingsState, context),
        );
      },
    );
  }

  Widget _buildBody(SettingsState settingsState, BuildContext context) {
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
                _buildUserProfileSection(),
                const SizedBox(height: 24),
                _buildSoundAndFeedbackSection(settingsState, context),
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

  Widget _buildUserProfileSection() {
    final String? uid = locator<AuthService>().currentUser?.uid;
    if (uid == null) return const SizedBox();

    return StreamBuilder<UserModel?>(
      stream: locator<AuthService>().userDocumentStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!;
        final int userLevel = user.level;
        final int userXP = user.xp;
        final int xpForNextLevel = user.xpForNextLevel;
        final int userCoins = user.coins;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserAvatarAndInfo(user, userLevel, userCoins),
              const SizedBox(height: 16),
              _buildLevelProgressSection(userXP, xpForNextLevel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatarAndInfo(dynamic user, int userLevel, int userCoins) {
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
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Text(
                    user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),

        // User info and coins
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Player',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Scabber',
                  fontWeight: FontWeight.bold,
                  color: transparentIndigoColor,
                ),
              ),
              Text(
                user?.email ?? '',
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

  Widget _buildSoundAndFeedbackSection(SettingsState settingsState, BuildContext context) {
    return Column(
      children: [
        SettingsSectionTitle(title: context.tr('sound_and_feedback')),
        SettingsTile(
          leading: Image.asset('assets/icons/volume.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('sound_effects'),
          trailing: Switch.adaptive(
            value: settingsState.soundEnabled,
            activeColor: Colors.green.shade400,
            onChanged: (value) {
              context.read<SettingsBloc>().add(SettingsEvent.toggleSound(enabled: value));
              if (value) {
                context.read<SettingsBloc>().add(SettingsEvent.playClickSound(assetPath: 'sounds/click.wav'));
              }
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/music.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('background_music'),
          trailing: Switch.adaptive(
            value: settingsState.musicEnabled,
            activeColor: Colors.green.shade400,
            onChanged: (value) {
              context.read<SettingsBloc>().add(SettingsEvent.toggleMusic(enabled: value));
              if (value) {
                context.read<SettingsBloc>().add(SettingsEvent.playBackgroundMusic(assetPath: 'sounds/zifromania_background.mp3'));
              } else {
                context.read<SettingsBloc>().add(SettingsEvent.stopBackgroundMusic());
              }
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/vibrate.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('vibration'),
          trailing: Switch.adaptive(
            value: settingsState.vibrationEnabled,
            activeColor: Colors.green.shade400,
            onChanged: (value) {
              context.read<SettingsBloc>().add(SettingsEvent.toggleVibration(enabled: value));
              if (value) {
                _soundService.hapticFeedback(HapticFeedbackType.light);
                context.read<SettingsBloc>().add(SettingsEvent.vibrate(duration: 300));
              }
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/feedback.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('send_feedback'),
          onTap: () {
            final route = PartialModalRoute(child: const FeedbackScreen());
            Navigator.push(context, route);
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
            final route = PartialModalRoute(child: const AboutZifroManiaScreen());
            Navigator.push(context, route);
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/privacy.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('privacy_policy'),
          onTap: () {
            final route = PartialModalRoute(child: const PrivacyPolicyScreen());
            Navigator.push(context, route);
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/service.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('terms_of_service'),
          onTap: () {
            final route = PartialModalRoute(child: const TermsOfServiceScreen());
            Navigator.push(context, route);
          },
        ),
      ],
    );
  }

  Widget _buildAccountAppSection(BuildContext context) {
    return Column(
      children: [
        SettingsSectionTitle(title: context.tr('account_and_app')),
        SettingsTile(
          leading: Image.asset('assets/icons/language.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('languages'),
          trailing: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return IconButton(
                key: languageButtonKey,
                icon: switch (state.language) {
                  'tr' => const Text('🇹🇷', style: TextStyle(fontSize: 20)),
                  'en' || _ => const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                },
                onPressed: () => _showLanguageMenu(context, languageButtonKey),
              );
            },
          ),
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/logout.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('logout'),
          onTap: () async {
            await _soundService.hapticFeedback(HapticFeedbackType.medium);
            if (context.mounted) context.read<AuthBloc>().add(AuthEvent.loggedOutStart());
          },
        ),
        SettingsTile(
          leading: Image.asset('assets/icons/quit.png', opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
          title: context.tr('quit'),
          onTap: () async {
            await _soundService.hapticFeedback(HapticFeedbackType.medium);
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
    ).then((selectedLanguage) {
      if (selectedLanguage != null) {
        _soundService.hapticFeedback(HapticFeedbackType.light);
        if (!context.mounted) return;
        context.setLocale(Locale(selectedLanguage));
        context.read<SettingsBloc>().add(SettingsEvent.setLanguage(language: selectedLanguage));
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

// Extracted reusable widgets
class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Scabber',
              color: transparentIndigoColor,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(height: 32, width: 32, child: leading),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: lightBrownColor),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
