import 'package:equation_quest/presentation/state_managment/auth/auth_bloc.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/settings_backg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            // User section
            // User profile section with game-style design
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.user;
                // Assuming these values would come from your user profile
                const int userLevel = 42; // Replace with actual user level
                const int userXP = 8300; // Replace with actual XP
                const int xpForNextLevel = 10000; // Replace with actual calculation
                final List<String> userAchievements = ['Math Master', 'Speed Demon', 'Perfect Score']; // Example achievements
                const int userCoins = 350; // Example game currency

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade100, Colors.purple.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and basic info section
                      Row(
                        children: [
                          // Avatar with level badge

                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.5),
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
                          // Level badge

                          const SizedBox(width: 16),

                          // User info and coins
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'Math Player',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Scabber',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Scabber',
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Coins indicator
                                Row(
                                  children: [
                                    const Text(
                                      'Lv. $userLevel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Image.asset(
                                      'assets/icons/star.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$userCoins',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Logout button
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Level progress section
                      Column(
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
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'XP: $userXP / $xpForNextLevel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Scabber',
                                  color: Colors.purple.shade700,
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
                                  widthFactor: userXP / xpForNextLevel, // Progress fraction
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                                      ),
                                    ),
                                  ),
                                ),
                                // Level markers
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    5, // 5 level markers
                                    (index) => Container(
                                      margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
                                      height: 20,
                                      width: 2,
                                      color: index != 0 && index != 4 ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
                                    ),
                                  ),
                                ),
                                // Level percentage
                                Center(
                                  child: Text(
                                    '${(userXP / xpForNextLevel * 100).toInt()}%',
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
                      ),

                      const SizedBox(height: 16),

                      // Achievements section
                      Text(
                        'Recent Achievements',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Scabber',
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: userAchievements
                              .map((achievement) => Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.amber.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          achievement,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Scabber',
                                            color: Colors.amber.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sound and Notifications section
            const SettingsSectionTitle(title: 'Sound & Feedback'),

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
            const SettingsSectionTitle(title: 'About'),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/information.png')),
              title: const Text('About Math Game', style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: Colors.black54)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {},
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/privacy.png')),
              title: const Text('Privacy Policy', style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: Colors.black54)),
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
                style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: Colors.black54),
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
                style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              onTap: () {},
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontFamily: 'Scabber',
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
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Scabber',
            color: Color.fromARGB(255, 75, 141, 194),
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
      title: Text(title, style: const TextStyle(fontFamily: 'Scabber', fontSize: 18, color: Colors.black54)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: Colors.green.shade400,
        onChanged: onChanged,
      ),
    );
  }
}
