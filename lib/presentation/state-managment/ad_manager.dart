import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/services/ad_service.dart';
import 'package:zifromania/services/game_limit_service.dart';

/// Reklam widget'larını idarə etmək üçün sinif
class AdManager {
  final AdService _adService = AdService();
  final GameLimitService? _gameLimitService;

  // Oyun üçün reklam göstərmə məntiqini idarə etmək üçün parametrlər
  int _gamePlayCount = 0;
  final int _interstitialAdThreshold = 3; // Hər 3 oyundan sonra interstitial reklam

  AdManager({GameLimitService? gameLimitService}) : _gameLimitService = gameLimitService;

  BannerAd? get bannerAd => _adService.bannerAd;
  bool get isBannerAdLoaded => _adService.isBannerAdLoaded;
  bool get isRewardedAdReady => _adService.isRewardedAdReady;

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

  /// Oyun bitdikdə reklam göstərmək üçün metod (callback ilə)
  void showAdAfterGame({VoidCallback? onAdClosed}) {
    _gamePlayCount++;

    // Hər _interstitialAdThreshold oyun sonrasında interstitial reklam göstərilir
    if (_gamePlayCount % _interstitialAdThreshold == 0) {
      _adService.showInterstitialAd(onAdClosed: onAdClosed);
    } else {
      // Reklam göstərilməyəcəksə, dərhal callback-i çağır
      onAdClosed?.call();
    }
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

  /// YENİ: Global flexible games əldə etmək üçün reward reklam göstər
  Future<bool> showRewardedAdForFlexibleGames({
    required Function() onRewardEarned,
    required Function(String error) onError,
  }) async {
    if (_gameLimitService == null) {
      onError('ad.service_unavailable'.tr());
      return false;
    }

    // Artıq 3 reklam izləyibsə, daha çox izləyə bilməz
    if (!_gameLimitService.canWatchAdForReward()) {
      onError('ad.daily_ads_limit_reached'.tr());
      return false;
    }

    if (!_adService.isRewardedAdReady) {
      onError('ad.ad_not_ready'.tr());
      return false;
    }

    try {
      bool rewardReceived = false;

      _adService.showRewardedAd(
        onUserEarnedReward: (adWithoutView, reward) async {
          // Global reklam sayını artır (bu avtomatik flexible games verəcək)
          await _gameLimitService.incrementGlobalAdWatchedCount();
          rewardReceived = true;
          onRewardEarned();
        },
      );

      return rewardReceived;
    } catch (e) {
      onError('ad.ad_failed'.tr(args: [e.toString()]));
      return false;
    }
  }

  /// YENİ: Global reklam vəziyyətini əldə et
  Map<String, dynamic>? getGlobalAdStatus() {
    return _gameLimitService?.getGlobalAdStatus();
  }

  /// YENİ: Kateqoriya statistikasını əldə et (flexible games daxil)
  Future<Map<String, dynamic>?> getCategoryStats(GameCategory category) async {
    return _gameLimitService?.getCategoryStats(category);
  }

  /// YENİ: Kateqoriyanın tam statusunu əldə et
  Map<String, dynamic> getCategoryFullStatus(GameCategory category) {
    if (_gameLimitService == null) {
      return {
        'error': 'ad.service_unavailable'.tr(),
        'canPlay': false,
      };
    }

    final categoryStats = _gameLimitService.getCategoryStats(category);
    final globalAdStatus = _gameLimitService.getGlobalAdStatus();

    return {
      'category': categoryStats,
      'globalAds': globalAdStatus,
      'canPlay': _gameLimitService.canPlayGame(category),
    };
  }

  /// Resursları azad etmək üçün metod
  void dispose() {
    _adService.dispose();
  }
}
