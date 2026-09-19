import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zifromania/shared/constants/app_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';

import 'package:zifromania/shared/widgets/back_button.dart';

class AboutZifroManiaScreen extends StatefulWidget {
  const AboutZifroManiaScreen({super.key});

  @override
  State<AboutZifroManiaScreen> createState() => _AboutZifroManiaScreenState();
}

class _AboutZifroManiaScreenState extends State<AboutZifroManiaScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoading) {
      _reloadWebView();
    }
  }

  Future<void> _initWebView() async {
    await _loadWebViewContent();
  }

  Future<void> _reloadWebView() async {
    setState(() {
      _isLoading = true;
    });
    await _loadWebViewContent();
  }

  Future<void> _loadWebViewContent() async {
    // Font'u base64 olarak yükle
    final fontBytes = await rootBundle.load('assets/fonts/Scabber.ttf');
    final fontBase64 = base64Encode(fontBytes.buffer.asUint8List());

    if (!mounted) return;
    final currentLocale = context.locale.languageCode;

    // HTML içeriğini oluştur
    _htmlContent = _getHtmlWithEmbeddedFont(fontBase64, currentLocale);

    // WebView controller'ını ayarla
    _controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_htmlContent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'about_zifromania'.tr(), // Çeviri için
          style: TextStyle(fontFamily: 'Scabber', fontSize: 22, color: lightBrownColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + kToolbarHeight),
          child: Stack(
            children: [
              if (!_isLoading && _htmlContent.isNotEmpty) WebViewWidget(controller: _controller),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  /// Dile göre HTML içeriği oluşturur
  String _getHtmlWithEmbeddedFont(String fontBase64, String languageCode) {
    // Çevirileri al
    final title = 'settings_about.about_title'.tr();
    final description = 'settings_about.about_description'.tr();
    final speedCalculation = 'settings_about.speed_calculation'.tr();
    final speedCalculationDesc = 'settings_about.speed_calculation_desc'.tr();
    final multiplicationTable = 'settings_about.multiplication_table'.tr();
    final multiplicationTableDesc = 'settings_about.multiplication_table_desc'.tr();
    final trueOrFalse = 'settings_about.true_or_false'.tr();
    final trueOrFalseDesc = 'settings_about.true_or_false_desc'.tr();
    final expertMode = 'settings_about.expert_mode'.tr();
    final expertModeDesc = 'settings_about.expert_mode_desc'.tr();
    final trainingMode = 'settings_about.training_mode'.tr();
    final trainingModeDesc = 'settings_about.training_mode_desc'.tr();

    final coinsAchievements = 'settings_about.coins_achievements'.tr();
    final dailyCoin = 'settings_about.daily_coin'.tr();
    final watchAds = 'settings_about.watch_ads'.tr();
    final spendCoins = 'settings_about.spend_coins'.tr();
    final trackAchievements = 'settings_about.track_achievements'.tr();

    final premiumSubscription = 'settings_about.premium_subscription'.tr();
    final premiumDescription = 'settings_about.premium_description'.tr();
    final oneMonth = 'settings_about.one_month'.tr();
    final threeMonths = 'settings_about.three_months'.tr();
    final twelveMonths = 'settings_about.twelve_months'.tr();

    final coinBundles = 'settings_about.coin_bundles'.tr();
    final coins100 = 'settings_about.coins_100'.tr();
    final coins500 = 'settings_about.coins_500'.tr();
    final coins1200 = 'settings_about.coins_1200'.tr();
    final coins2500 = 'settings_about.coins_2500'.tr();

    final conclusion = 'settings_about.about_conclusion'.tr();

    return '''<!DOCTYPE html>
<html lang="$languageCode">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>

  <style>
    @font-face {
      font-family: 'Scabber';
      src: url(data:font/truetype;charset=utf-8;base64,$fontBase64) format('truetype');
      font-weight: normal;
      font-style: normal;
    }

    body {
      font-family: 'Scabber', -apple-system, BlinkMacSystemFont, 'Segoe UI',
                   Roboto, Helvetica, Arial, sans-serif;
      margin: 0;
      padding: 16px;
      line-height: 1.6;
      background-color: transparent !important;
      color: #D7CCC880;
      direction: ltr;
    }
    h1 {
      font-size: 1.8rem;
      margin-top: 0;
      color: #8C9EFF99;
    }
    h2 {
      font-size: 1.4rem;
      margin-top: 1.4em;
      color: #8C9EFF99;
    }
    strong { color: #8C9EFF99; }
    ul { padding-left: 1.2em; padding-right: 1.2em; }
    li { margin-bottom: 0.4em; }
    section { margin-bottom: 1.4em; }
  </style>
</head>
<body>
  <h1>$title</h1>

  <section>
    <p>
      <strong>ZifroMania</strong> $description
    </p>
    <ul>
      <li><strong>$speedCalculation</strong> – $speedCalculationDesc</li>
      <li><strong>$multiplicationTable</strong> – $multiplicationTableDesc</li>
      <li><strong>$trueOrFalse</strong> – $trueOrFalseDesc</li>
      <li><strong>$expertMode</strong> – $expertModeDesc</li>
      <li><strong>$trainingMode</strong> – $trainingModeDesc</li>
    </ul>
  </section>

  <section>
    <h2>$coinsAchievements</h2>
    <ul>
      <li>$dailyCoin</li>
      <li>$watchAds</li>
      <li>$spendCoins</li>
      <li>$trackAchievements</li>
    </ul>
  </section>

  <section>
    <h2>$premiumSubscription</h2>
    <p>$premiumDescription</p>
    <ul>
      <li>$oneMonth</li>
      <li>$threeMonths</li>
      <li>$twelveMonths</li>
    </ul>
  </section>

  <section>
    <h2>$coinBundles</h2>
    <ul>
      <li>$coins100</li>
      <li>$coins500</li>
      <li>$coins1200</li>
      <li>$coins2500</li>
    </ul>
  </section>

  <p>$conclusion</p>
</body>
</html>
''';
  }
}
