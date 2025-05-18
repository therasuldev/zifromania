import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/presentation/state_managment/ad_manager.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adManager = locator<AdManager>();
    final ad = adManager.bannerAd;

    if (adManager.isBannerAdLoaded && ad != null) {
      return Container(
        alignment: Alignment.center,
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    } else {
      return const SizedBox(height: 50);
    }
  }
}
