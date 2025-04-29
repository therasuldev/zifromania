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
              leading: Image.asset('assets/icons/volume.png'),
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
              leading: Image.asset('assets/icons/music.png'),
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
              leading: Image.asset('assets/icons/vibrate.png'),
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
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/information.png')),
              title: const Text('About Math Game', style: TextStyle(fontFamily: 'rimouskisb')),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {},
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/privacy.png')),
              title: const Text('Privacy Policy', style: TextStyle(fontFamily: 'rimouskisb')),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {
                // Navigate to privacy policy
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/service.png')),
              title: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontFamily: 'rimouskisb',
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {
                // Navigate to terms of service
              },
            ),
            Divider(color: Colors.grey.shade200),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/logout.png')),
              title: const Text(
                'Quit',
                style: TextStyle(fontFamily: 'rimouskisb'),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {},
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontFamily: 'rimouskisb',
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

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'rimouskisb',
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
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(height: 32, width: 32, child: leading),
      title: Text(title, style: TextStyle(fontFamily: 'rimouskisb')),
      trailing: Switch.adaptive(
        value: value,
        activeColor: Colors.green.shade400,
        onChanged: onChanged,
      ),
    );
  }
}
