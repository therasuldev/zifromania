import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:zifromania/presentation/common/back_button.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final Color color;
  final DateTime? unlockedDate;
  final int? score; // Opsiyonel skor değeri

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
    this.unlockedDate,
    this.score,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showConfetti = false;
  final GlobalKey _shareCardKey = GlobalKey();

  // Tema ayarları
  final Color _backgroundColor = const Color(0xFF1F2136);
  final Color _cardBackgroundColor = const Color(0xFF2A2D43);
  final Color _tabBackgroundColor = const Color(0xFF2A2D43);
  final Color _textColor = Colors.white;
  final Color _subTextColor = Colors.white70;

  final List<Achievement> _achievements = [
    Achievement(
      id: 'math_master',
      title: 'Math Master',
      description: 'Matematik kategorisinde 10 soruyu doğru cevaplayın',
      icon: 'assets/icons/music.png',
      isUnlocked: true,
      color: const Color(0xFF4C87FF),
      unlockedDate: DateTime.now().subtract(const Duration(days: 2)),
      score: 1250,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: '30 saniyeden az sürede 5 soruyu doğru cevaplayın',
      icon: 'assets/icons/replay.png',
      isUnlocked: true,
      color: const Color(0xFFFF5757),
      unlockedDate: DateTime.now().subtract(const Duration(days: 1)),
      score: 950,
    ),
    Achievement(
      id: 'perfect_score',
      title: 'Perfect Score',
      description: 'Herhangi bir kategoride tüm soruları doğru cevaplayın',
      icon: 'assets/icons/achievements.png',
      isUnlocked: true,
      color: const Color(0xFFFFB74D),
      unlockedDate: DateTime.now(),
      score: 2000,
    ),
    Achievement(
      id: 'geometry_guru',
      title: 'Geometry Guru',
      description: 'Geometri kategorisinde 15 soruyu doğru cevaplayın',
      icon: 'assets/icons/expert.png',
      isUnlocked: false,
      color: const Color(0xFF66BB6A),
      unlockedDate: null,
      score: null,
    ),
    Achievement(
      id: 'algebra_ace',
      title: 'Algebra Ace',
      description: 'Cebir kategorisinde ardışık 5 soruyu doğru cevaplayın',
      icon: 'assets/icons/home.png',
      isUnlocked: false,
      color: const Color(0xFFAB47BC),
      unlockedDate: null,
      score: null,
    ),
    Achievement(
      id: 'calc_champion',
      title: 'Calculation Champion',
      description: 'Aritmetik kategorisinde 20 soruyu doğru cevaplayın',
      icon: 'assets/icons/information.png',
      isUnlocked: false,
      color: const Color(0xFFFF9800),
      unlockedDate: null,
      score: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Sayfaya girildiğinde konfeti animasyonu
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   setState(() {
    //     _showConfetti = true;
    //   });
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget'ı görüntüye dönüştürme fonksiyonu
  Future<ByteData?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      print("Resim kaydetme hatası: $e");
      return null;
    }
  }

  // Görüntüyü kaydetme ve paylaşma
  Future<void> _shareAchievementWithImage(Achievement achievement) async {
    // Konfeti animasyonunu göster
    setState(() {
      _showConfetti = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      final ByteData? byteData = await _capturePng();

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final File file = await File('${tempDir.path}/achievement.png').create();
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Ben "${achievement.title}" başarısını kazandım! Matematik Oyunu\'nda sen de deneyebilirsin!',
          subject: 'Matematik Oyunu Başarısı',
        );

        // Konfeti animasyonunu kapat
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AchievementDetailsSheet(
        achievement: achievement,
        onShare: () => _shareAchievementWithImage(achievement),
        shareCardKey: _shareCardKey,
        backgroundColor: _backgroundColor,
        cardBackgroundColor: _cardBackgroundColor,
        textColor: _textColor,
        subTextColor: _subTextColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();

    // Toplam skor hesaplama
    int totalScore = _achievements.where((a) => a.isUnlocked).fold(0, (sum, achievement) => sum + (achievement.score ?? 0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const CustomBackButton(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _tabBackgroundColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorAnimation: TabIndicatorAnimation.elastic,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C87FF), Color(0xFF6A6FFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C87FF).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                unselectedLabelColor: _textColor.withOpacity(0.5),
                labelColor: Colors.white,
                labelStyle: const TextStyle(fontSize: 12),
                tabs: [
                  Tab(text: 'Kazanılan (${unlockedAchievements.length})'),
                  Tab(text: 'Kilitli (${lockedAchievements.length})'),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Arka plan animasyonu
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/settings_backg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Tab içeriği
            Padding(
              padding: const EdgeInsets.only(top: 140),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Unlocked Achievements Tab
                  unlockedAchievements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/empty.png',
                                width: 100,
                                height: 100,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz hiç başarı kazanmadınız.',
                                style: TextStyle(color: _subTextColor),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Anasayfaya dönüş
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C87FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Oyuna Dön'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75, // Daha dikey kartlar
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: unlockedAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = unlockedAchievements[index];
                            return AchievementCard(
                              achievement: achievement,
                              onTap: () => _showAchievementDetails(context, achievement),
                              backgroundColor: _cardBackgroundColor,
                              textColor: _textColor,
                              subTextColor: _subTextColor,
                            );
                          },
                        ),

                  // Locked Achievements Tab
                  lockedAchievements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/trophy.png',
                                width: 100,
                                height: 100,
                                color: Colors.amber,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tebrikler! Tüm başarıları kazandınız!',
                                style: TextStyle(color: _textColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gerçek bir şampiyonsunuz!',
                                style: TextStyle(color: _subTextColor),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75, // Daha dikey kartlar
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: lockedAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = lockedAchievements[index];
                            return AchievementCard(
                              achievement: achievement,
                              onTap: () => _showAchievementDetails(context, achievement),
                              backgroundColor: _cardBackgroundColor,
                              textColor: _textColor,
                              subTextColor: _subTextColor,
                            );
                          },
                        ),
                ],
              ),
            ),
            // Konfeti animasyonu (konditional olarak gösteriliyor)
            // if (_showConfetti)
            //   Positioned.fill(
            //     child: IgnorePointer(
            //       child: Lottie.asset(
            //         'assets/lotties/collected.json',
            //         animate: true,
            //         repeat: true,
            //         onLoaded: (composition) {
            //           Future.delayed(composition.duration * 2, () {
            //             if (mounted) {
            //               setState(() {
            //                 _showConfetti = false;
            //               });
            //             }
            //           });
            //         },
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
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
              color: achievement.isUnlocked ? achievement.color.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: achievement.isUnlocked ? Border.all(color: achievement.color.withOpacity(0.5), width: 2) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Arkaplan deseni
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
                      color: achievement.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),

            // Başarı içeriği
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Başarı ikonu
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: achievement.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: achievement.color.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                  )
                                ]
                              : null,
                        ),
                        child: achievement.isUnlocked
                            ? Image.asset(
                                achievement.icon,
                                width: 32,
                                height: 32,
                              )
                            : Icon(
                                Icons.lock,
                                size: 32,
                                color: Colors.grey.withOpacity(0.5),
                              ),
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
                                  color: achievement.color.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              '+${achievement.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Başarı başlığı
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked ? achievement.color : Colors.grey.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Başarı açıklaması
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Kazanıldı etiketi
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            achievement.color.withOpacity(0.8),
                            achievement.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: achievement.color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KAZANILDI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'KİLİTLİ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
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
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Paylaşılabilir kart (ekran görüntüsünü almak için)
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
                    achievement.isUnlocked ? achievement.color.withOpacity(0.1) : cardBackgroundColor,
                  ],
                ),
                border:
                    Border.all(color: achievement.isUnlocked ? achievement.color.withOpacity(0.5) : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Şampiyonluk kupası
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hale efekti
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // İkon container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: achievement.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: achievement.color.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                  )
                                ]
                              : null,
                        ),
                        child: achievement.isUnlocked
                            ? Image.asset(
                                achievement.icon,
                                width: 48,
                                height: 48,
                              )
                            : Icon(
                                Icons.lock,
                                size: 48,
                                color: Colors.grey.withOpacity(0.7),
                              ),
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
                                  color: achievement.color.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '+${achievement.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Başlık
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked ? achievement.color : Colors.grey.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Açıklama
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kazanıldı tarihi ve rozeti
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            achievement.color.withOpacity(0.8),
                            achievement.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: achievement.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'KAZANILDI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'KİLİTLİ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Kazanıldı tarihi (sadece kazanılan başarılar için)
                  if (achievement.isUnlocked && achievement.unlockedDate != null)
                    Text(
                      'Kazanıldığı tarih: ${achievement.unlockedDate!.day}/${achievement.unlockedDate!.month}/${achievement.unlockedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),

                  // Oyun logosu
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/app_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MATEMATİK OYUNU',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
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
              label: const Text(
                'PAYLAŞ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
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
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Kapat butonu
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: textColor.withOpacity(0.7),
            ),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }
}
