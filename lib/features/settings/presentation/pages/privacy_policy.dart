import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';

import 'package:zifromania/presentation/common/back_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
    // Dil değiştiğinde WebView'i yeniden yükle
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

    // Mevcut dil kodunu al
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
              setState(() => _isLoading = false);
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
        backgroundColor: Colors.transparent,
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        title: Text(
          'privacy_policy'.tr(), // Çeviri için
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
    final title = 'settings_privacy_policy.privacy_policy_title'.tr();
    final effectiveDate = 'settings_privacy_policy.effective_date'.tr();

    final introductionTitle = 'settings_privacy_policy.privacy_introduction_title'.tr();
    final introductionText = 'settings_privacy_policy.privacy_introduction_text'.tr();

    final dataWeCollect = 'settings_privacy_policy.data_we_collect'.tr();
    final accountData = 'settings_privacy_policy.account_data'.tr();
    final accountDataDesc = 'settings_privacy_policy.account_data_desc'.tr();
    final deviceData = 'settings_privacy_policy.device_data'.tr();
    final deviceDataDesc = 'settings_privacy_policy.device_data_desc'.tr();
    final usageData = 'settings_privacy_policy.usage_data'.tr();
    final usageDataDesc = 'settings_privacy_policy.usage_data_desc'.tr();
    final purchaseData = 'settings_privacy_policy.purchase_data'.tr();
    final purchaseDataDesc = 'settings_privacy_policy.purchase_data_desc'.tr();
    final analyticsData = 'settings_privacy_policy.analytics_data'.tr();
    final analyticsDataDesc = 'settings_privacy_policy.analytics_data_desc'.tr();

    final howWeUseData = 'settings_privacy_policy.how_we_use_data'.tr();
    final useData1 = 'settings_privacy_policy.use_data_1'.tr();
    final useData2 = 'settings_privacy_policy.use_data_2'.tr();
    final useData3 = 'settings_privacy_policy.use_data_3'.tr();
    final useData4 = 'settings_privacy_policy.use_data_4'.tr();
    final useData5 = 'settings_privacy_policy.use_data_5'.tr();

    final thirdPartyServices = 'settings_privacy_policy.third_party_services'.tr();
    final googleAdmob = 'settings_privacy_policy.google_admob'.tr();
    final googleAdmobDesc = 'settings_privacy_policy.google_admob_desc'.tr();
    final firebaseAnalytics = 'settings_privacy_policy.firebase_analytics'.tr();
    final firebaseAnalyticsDesc = 'settings_privacy_policy.firebase_analytics_desc'.tr();
    final googlePlayBilling = 'settings_privacy_policy.google_play_billing'.tr();
    final googlePlayBillingDesc = 'settings_privacy_policy.google_play_billing_desc'.tr();

    final dataSecurity = 'settings_privacy_policy.data_security'.tr();
    final dataSecurityText = 'settings_privacy_policy.data_security_text'.tr();

    final childrensPrivacy = 'settings_privacy_policy.childrens_privacy'.tr();
    final childrensPrivacyText = 'settings_privacy_policy.childrens_privacy_text'.tr();

    final yourRights = 'settings_privacy_policy.your_rights'.tr();
    final yourRightsText = 'settings_privacy_policy.your_rights_text'.tr();

    final changesToPolicy = 'settings_privacy_policy.changes_to_policy'.tr();
    final changesToPolicyText = 'settings_privacy_policy.changes_to_policy_text'.tr();

    final contactUs = 'settings_privacy_policy.contact_us'.tr();
    final contactUsText = 'settings_privacy_policy.contact_us_text'.tr();

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
    ul { padding-left: 1.2em; }
    li { margin-bottom: 0.4em; }
    section {
      margin-bottom: 1.8em;
      background-color: transparent !important;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    strong { color: #8C9EFF99; }
    a { color: white; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p><em>$effectiveDate</em></p>

  <section>
    <h2>1. $introductionTitle</h2>
    <p>$introductionText</p>
  </section>

  <section>
    <h2>2. $dataWeCollect</h2>
    <ul>
      <li><strong>$accountData</strong> $accountDataDesc</li>
      <li><strong>$deviceData</strong> $deviceDataDesc</li>
      <li><strong>$usageData</strong> $usageDataDesc</li>
      <li><strong>$purchaseData</strong> $purchaseDataDesc</li>
      <li><strong>$analyticsData</strong> $analyticsDataDesc</li>
    </ul>
  </section>

  <section>
    <h2>3. $howWeUseData</h2>
    <ul>
      <li>$useData1</li>
      <li>$useData2</li>
      <li>$useData3</li>
      <li>$useData4</li>
      <li>$useData5</li>
    </ul>
  </section>

  <section>
    <h2>4. $thirdPartyServices</h2>
    <ul>
      <li><strong>$googleAdmob</strong> – $googleAdmobDesc <a href="https://policies.google.com/privacy">https://policies.google.com/privacy</a>.</li>
      <li><strong>$firebaseAnalytics</strong> – $firebaseAnalyticsDesc</li>
      <li><strong>$googlePlayBilling</strong> – $googlePlayBillingDesc</li>
    </ul>
  </section>

  <section>
    <h2>5. $dataSecurity</h2>
    <p>$dataSecurityText</p>
  </section>

  <section>
    <h2>6. $childrensPrivacy</h2>
    <p>$childrensPrivacyText</p>
  </section>

  <section>
    <h2>7. $yourRights</h2>
    <p>$yourRightsText</p>
  </section>

  <section>
    <h2>8. $changesToPolicy</h2>
    <p>$changesToPolicyText</p>
  </section>

  <section>
    <h2>9. $contactUs</h2>
    <p>$contactUsText <a href="mailto:rasul.ramixanov@gmail.com">rasul.ramixanov@gmail.com</a>.</p>
  </section>

</body>
</html>
''';
  }
}
