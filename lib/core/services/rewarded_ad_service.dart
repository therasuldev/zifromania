import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService();

  final bool _testMode = kDebugMode;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Test Ad Unit IDs
  final String _testRewardedAdUnitId = Platform.isAndroid ? 'ca-app-pub-3940256099942544/5224354917' : 'ca-app-pub-3940256099942544/1712485313';

  // Real Ad Unit IDs
  final String _realRewardedAdUnitId = Platform.isAndroid ? 'ca-app-pub-7254369494202990/7653383408' : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  String get _adUnitId => _testMode ? _testRewardedAdUnitId : _realRewardedAdUnitId;

  bool get isRewardedAdReady => _isRewardedAdReady;

  /// Mobile Ads SDK initialization
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  /// Rewarded reklamı yükləmək
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Rewarded ad loaded successfully.');

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;

              // load the next rewarded ad after the current one is dismissed
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
              debugPrint('Failed to show rewarded ad: ${error.message}');
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          _rewardedAd = null;
          debugPrint('Failed to load rewarded ad: ${error.message}');
          // Retry loading the ad after a delay
          Future.delayed(const Duration(minutes: 1), loadRewardedAd);
        },
      ),
    );
  }

  /// Rewarded reklamı göstərmək
  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    VoidCallback? onAdNotReady,
  }) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      debugPrint('Rewarded ad is not ready yet. Reloading...');
      onAdNotReady?.call();
      loadRewardedAd();
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}

// Provider for RewardedAdService
final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service.dispose());
  return service;
});
