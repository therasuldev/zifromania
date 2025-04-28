import 'package:equation_quest/presentation/state_managment/auth/auth_bloc.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_event.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   title: Text(
      //     'Settings',
      //     style: TextStyle(
      //       color: Colors.blue.shade800,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.blue.shade800),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // User section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.user;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null
                            ? Text(
                                user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Math Player',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: Colors.red.shade400,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<AuthBloc>().add(AuthEvent.loggedOut());
                                  },
                                  child: Text(
                                    'Sign Out',
                                    style: TextStyle(color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sound and Notifications section
            SettingsSectionTitle(title: 'Sound & Feedback'),

            // Sound switch
            SettingsSwitch(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),

            // Music switch
            SettingsSwitch(
              icon: Icons.music_note,
              title: 'Background Music',
              value: _musicEnabled,
              onChanged: (value) {
                setState(() {
                  _musicEnabled = value;
                });
              },
            ),

            // Vibration switch
            SettingsSwitch(
              icon: Icons.vibration,
              title: 'Vibration',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // About section
            SettingsSectionTitle(title: 'About'),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: Colors.blue.shade400),
              title: const Text('About Math Game'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {
                // Navigate to about page
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.privacy_tip_outlined, color: Colors.blue.shade400),
              title: const Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {
                // Navigate to privacy policy
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description_outlined, color: Colors.blue.shade400),
              title: const Text('Terms of Service'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {
                // Navigate to terms of service
              },
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Common widgets
class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Divider(color: Colors.grey.shade200),
      ],
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue.shade400),
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        activeColor: Colors.blue.shade400,
        onChanged: onChanged,
      ),
    );
  }
}
