import 'package:zifromania/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reklam widget'larını idarə etmək üçün sinif
class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  final AdService _adService = AdService();

  // Oyun üçün reklam göstərmə məntiqini idarə etmək üçün parametrlər
  final int _gamePlayCount = 0;
  final int _interstitialAdThreshold = 3; // Hər 3 oyundan sonra interstitial reklam

  /// AdMob-u başlatmaq üçün metod
  Future<void> initialize() async {
    await _adService.initialize();
    _adService.loadBannerAd();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
  }

  /// Banner reklam widget'ını yaratmaq üçün metod
  Widget getBannerAdWidget() {
    if (_adService.isBannerAdLoaded && _adService.bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _adService.bannerAd!.size.width.toDouble(),
        height: _adService.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _adService.bannerAd!),
      );
    }
    // Reklam yüklənməyibsə, boş konteyner göstər
    return const SizedBox(height: 50);
  }

  /// Oyun bitdikdə reklam göstərmək üçün metod
  void showAdAfterGame() {
    // _gamePlayCount++;

    // Hər _interstitialAdThreshold oyun sonrasında interstitial reklam göstərilir
    //if (_gamePlayCount % _interstitialAdThreshold == 0) {
    _adService.showInterstitialAd();
    //}
  }

  /// Xüsusi mükafat üçün reklam göstərmək üçün metod
  void showRewardedAdForBonus({
    required Function(RewardItem reward) onRewardEarned,
    required Function() onRewardedAdClosed,
  }) {
    if (_adService.isRewardedAdReady) {
      _adService.showRewardedAd(onUserEarnedReward: (adWithoutView, reward) {
        onRewardEarned(reward);
      });
    } else {
      onRewardedAdClosed();
    }
  }

  /// Resursları azad etmək üçün metod
  void dispose() {
    _adService.dispose();
  }
}
