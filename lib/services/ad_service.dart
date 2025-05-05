import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Tətbiq üçün reklam xidmətini idarə edən sinif
class AdService {
  static final AdService _instance = AdService._internal();
  
  factory AdService() => _instance;
  
  AdService._internal();
  
  // Test və ya real reklam ID-ləri üçün flag
  final bool _testMode = kDebugMode;
  
  // Banner reklamları
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Interstitial reklamları
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  
  // Reward reklamları
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  
  // Test ID-ləri
  final String _testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';
      
  final String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
      
  final String _testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
  
  // Real ID-ləri
  // TODO: Buraya öz real adMob ID-lərinizi əlavə edin
  final String _realBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
      
  final String _realInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
      
  final String _realRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' 
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // Banner ad ID getter
  String get bannerAdUnitId => _testMode ? _testBannerAdUnitId : _realBannerAdUnitId;
  
  // Interstitial ad ID getter
  String get interstitialAdUnitId => _testMode ? _testInterstitialAdUnitId : _realInterstitialAdUnitId;
  
  // Rewarded ad ID getter
  String get rewardedAdUnitId => _testMode ? _testRewardedAdUnitId : _realRewardedAdUnitId;
  
  // Banner ad durumu
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  
  // Interstitial ad durumu
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  
  // Rewarded ad durumu
  bool get isRewardedAdReady => _isRewardedAdReady;
  
  /// AdMob SDK-nı başlatmaq üçün metod
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  
  /// Banner reklamını yükləmək üçün metod
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
          debugPrint('Banner reklamı uğurla yükləndi');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
          debugPrint('Banner reklamı yüklənmədi: ${error.message}');
        },
      ),
    );
    _bannerAd?.load();
  }
  
  /// Interstitial reklamını yükləmək üçün metod
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial reklamı uğurla yükləndi');
          
          // Reklamı bağlandıqdan sonra yenidən yükləmək üçün dinləyici əlavə etmək
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Yenidən yüklə
              debugPrint('Interstitial reklamı bağlandı');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Yenidən yüklə
              debugPrint('Interstitial reklamı göstərmək uğursuz oldu: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          debugPrint('Interstitial reklamı yüklənmədi: ${error.message}');
          // Bir müddət sonra yenidən yükləmək
          Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
        },
      ),
    );
  }
  
  /// Interstitial reklamını göstərmək üçün metod
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial reklamı hazır deyil, yenidən yüklənir...');
      loadInterstitialAd();
    }
  }
  
  /// Reward reklamını yükləmək üçün metod
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Reward reklamı uğurla yükləndi');
          
          // Reklamı bağlandıqdan sonra yenidən yükləmək üçün dinləyici əlavə etmək
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Yenidən yüklə
              debugPrint('Reward reklamı bağlandı');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Yenidən yüklə
              debugPrint('Reward reklamı göstərmək uğursuz oldu: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          debugPrint('Reward reklamı yüklənmədi: ${error.message}');
          // Bir müddət sonra yenidən yükləmək
          Future.delayed(const Duration(minutes: 1), loadRewardedAd);
        },
      ),
    );
  }
  
  /// Reward reklamını göstərmək üçün metod
  void showRewardedAd({required OnUserEarnedRewardCallback onUserEarnedReward}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      debugPrint('Reward reklamı hazır deyil, yenidən yüklənir...');
      loadRewardedAd();
    }
  }
  
  /// Banner reklamını əldə etmək üçün getter
  BannerAd? get bannerAd => _bannerAd;
  
  /// Resursları azad etmək üçün metod
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
  }
}