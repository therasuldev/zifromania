import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/common/partial_modal_route.dart';
import 'package:zifromania/presentation/screens/about_zifromania.dart';
import 'package:zifromania/presentation/screens/privacy_policy.dart';
import 'package:zifromania/presentation/screens/terms_of_service.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_event.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_state.dart';
import 'package:zifromania/presentation/state_managment/settings/settings_bloc.dart';
import 'package:zifromania/services/sound_service.dart';

import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _soundService.init();
  }

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
          // opacity: 0.9,
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
            'Settings',
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        // These would come from user profile in real app
        final int userLevel = user?.level ?? 0;
        final int userXP = user?.xp ?? 0;
        final int xpForNextLevel = user?.xpForNextLevel ?? 1000;
        // final List<String> userAchievements = user?.achievements ?? [];
        final int userCoins = user?.coins ?? 0;

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
              _buildUserAvatarAndInfo(user, userLevel, userCoins),
              const SizedBox(height: 16),
              _buildLevelProgressSection(userXP, xpForNextLevel),
              const SizedBox(height: 16),
              //_buildAchievementsSection(userAchievements),
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
              const SizedBox(height: 4),
              // Coins indicator
              // Row(
              //   children: [
              // Text(
              //   'Lv. $userLevel',
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontFamily: 'Scabber',
              //     fontWeight: FontWeight.bold,
              //     color: Colors.red,
              //   ),
              // ),
              // const SizedBox(width: 48),
              // Image.asset(
              //   'assets/icons/star.png',
              //   height: 20,
              //   width: 20,
              // ),
              // const SizedBox(width: 4),
              // Text(
              //   '$userCoins',
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontFamily: 'Scabber',
              //     fontWeight: FontWeight.bold,
              //     color: Colors.amber,
              //   ),
              // ),
              //   ],
              // ),
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
              'Level Progress',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Scabber',
                color: transparentIndigoColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'XP: $userXP / $xpForNextLevel',
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

  // Widget _buildAchievementsSection(List<String> userAchievements) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Recent Achievements',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontFamily: 'Scabber',
  //           color: softIndigoColor,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: userAchievements.map((achievement) => _buildAchievementBadge(achievement)).toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildAchievementBadge(String achievement) {
  //   return Container(
  //     margin: const EdgeInsets.only(right: 8),
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: Colors.amber.shade100,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.amber.shade300),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           Icons.star,
  //           size: 16,
  //           color: Colors.amber.shade700,
  //         ),
  //         const SizedBox(width: 4),
  //         Text(
  //           achievement,
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontFamily: 'Scabber',
  //             color: Colors.amber.shade800,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSoundAndFeedbackSection(SettingsState settingsState, BuildContext context) {
    return Column(
      children: [
        const SettingsSectionTitle(title: 'Sound & Feedback'),
        _buildSettingSwitch(
          context: context,
          iconPath: 'assets/icons/volume.png',
          title: 'Sound Effects',
          value: settingsState.soundEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(SettingsEvent.toggleSound(enabled: value));
            if (value) {
              context.read<SettingsBloc>().add(SettingsEvent.playClickSound(assetPath: 'sounds/click.wav'));
            }
          },
        ),
        _buildSettingSwitch(
          context: context,
          iconPath: 'assets/icons/music.png',
          title: 'Background Music',
          value: settingsState.musicEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(SettingsEvent.toggleMusic(enabled: value));
            if (value) {
              context.read<SettingsBloc>().add(SettingsEvent.playBackgroundMusic(assetPath: 'sounds/zifromania_background.mp3'));
            } else {
              context.read<SettingsBloc>().add(SettingsEvent.stopBackgroundMusic());
            }
          },
        ),
        _buildSettingSwitch(
          context: context,
          iconPath: 'assets/icons/vibrate.png',
          title: 'Vibration',
          value: settingsState.vibrationEnabled,
          onChanged: (value) {
            context.read<SettingsBloc>().add(SettingsEvent.toggleVibration(enabled: value));
            if (value) {
              _soundService.hapticFeedback(HapticFeedbackType.light);
              context.read<SettingsBloc>().add(SettingsEvent.vibrate(duration: 300));
            }
          },
        ),
        _buildNavigationTile(
          iconPath: 'assets/icons/feedback.png',
          title: 'Send Feedback',
          onTap: () {
            final route = PartialModalRoute(child: const FeedbackScreen());
            Navigator.push(context, route);
          },
        ),
      ],
    );
  }

  Widget _buildSettingSwitch({
    required BuildContext context,
    required String iconPath,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingsSwitch(
      leading: Image.asset(iconPath, opacity: Animation.fromValueListenable(ValueNotifier(0.7))),
      title: title,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        const SettingsSectionTitle(title: 'About'),
        _buildNavigationTile(
          iconPath: 'assets/icons/information.png',
          title: 'About Zifromania',
          onTap: () {
            final route = PartialModalRoute(child: const AboutZifroManiaScreen());
            Navigator.push(context, route);
          },
        ),
        _buildNavigationTile(
          iconPath: 'assets/icons/privacy.png',
          title: 'Privacy Policy',
          onTap: () {
            final route = PartialModalRoute(child: const PrivacyPolicyScreen());
            Navigator.push(context, route);
          },
        ),
        _buildNavigationTile(
          iconPath: 'assets/icons/service.png',
          title: 'Terms of Service',
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
        const SettingsSectionTitle(title: 'Account & App'),
        _buildNavigationTile(
          iconPath: 'assets/icons/logout.png',
          title: 'Logout',
          onTap: () async {
            await _soundService.hapticFeedback(HapticFeedbackType.medium);
            if (context.mounted) context.read<AuthBloc>().add(AuthEvent.loggedOutStart());
          },
        ),
        _buildNavigationTile(
          iconPath: 'assets/icons/quit.png',
          title: 'Quit',
          onTap: () async {
            await _soundService.hapticFeedback(HapticFeedbackType.medium);
            await SystemNavigator.pop();
          },
        ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(
          height: 32,
          width: 32,
          child: Image.asset(
            iconPath,
            opacity: Animation.fromValueListenable(ValueNotifier(0.7)),
          )),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: lightBrownColor),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        'Version 1.0.0',
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

class SettingsSwitch extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(height: 32, width: 32, child: leading),
      title: Text(title, style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: lightBrownColor)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: Colors.green.shade400,
        onChanged: onChanged,
      ),
    );
  }
}
