import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zifromania/shared/constants/app_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';

import 'package:zifromania/shared/widgets/back_button.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
        backgroundColor: Colors.transparent,
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        title: Text(
          'terms.terms_of_service'.tr(), // Çeviri için
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
    final title = 'terms.title'.tr();
    final effectiveDate = 'terms.effective_date'.tr();

    final acceptanceTitle = 'terms.acceptance.title'.tr();
    final acceptanceContent = 'terms.acceptance.content'.tr();

    final eligibilityTitle = 'terms.eligibility.title'.tr();
    final eligibilityContent = 'terms.eligibility.content'.tr();

    final accountsTitle = 'terms.accounts.title'.tr();
    final accountsContent = 'terms.accounts.content'.tr();

    final gameplayTitle = 'terms.gameplay.title'.tr();
    final gameplayRule1 = 'terms.gameplay.rule1'.tr();
    final gameplayRule2 = 'terms.gameplay.rule2'.tr();
    final gameplayRule3 = 'terms.gameplay.rule3'.tr();

    final virtualCurrencyTitle = 'terms.virtual_currency.title'.tr();
    final virtualCurrencyContent = 'terms.virtual_currency.content'.tr();

    final subscriptionsTitle = 'terms.subscriptions.title'.tr();
    final productHeader = 'terms.subscriptions.product'.tr();
    final priceHeader = 'terms.subscriptions.price'.tr();
    final billingHeader = 'terms.subscriptions.billing'.tr();
    final premium1Month = 'terms.subscriptions.premium_1_month'.tr();
    final premium3Months = 'terms.subscriptions.premium_3_months'.tr();
    final premium12Months = 'terms.subscriptions.premium_12_months'.tr();
    final coins100 = 'terms.subscriptions.coins_100'.tr();
    final coins500 = 'terms.subscriptions.coins_500'.tr();
    final coins1200 = 'terms.subscriptions.coins_1200'.tr();
    final coins2500 = 'terms.subscriptions.coins_2500'.tr();
    final renewsMonthly = 'terms.subscriptions.renews_monthly'.tr();
    final renews3Months = 'terms.subscriptions.renews_3_months'.tr();
    final renewsAnnually = 'terms.subscriptions.renews_annually'.tr();
    final oneTime = 'terms.subscriptions.one_time'.tr();
    final subscriptionsNote = 'terms.subscriptions.note'.tr();

    final advertisingTitle = 'terms.advertising.title'.tr();
    final advertisingContent = 'terms.advertising.content'.tr();

    final privacyTitle = 'terms.privacy.title'.tr();
    final privacyContent = 'terms.privacy.content'.tr();

    final intellectualTitle = 'terms.intellectual.title'.tr();
    final intellectualContent = 'terms.intellectual.content'.tr();

    final disclaimerTitle = 'terms.disclaimer.title'.tr();
    final disclaimerContent = 'terms.disclaimer.content'.tr();

    final limitationTitle = 'terms.limitation.title'.tr();
    final limitationContent = 'terms.limitation.content'.tr();

    final terminationTitle = 'terms.termination.title'.tr();
    final terminationContent = 'terms.termination.content'.tr();

    final contactTitle = 'terms.contact.title'.tr();
    final contactContent = 'terms.contact.content'.tr();

    final finalNote = 'terms.final_note'.tr();

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
      font-style: normal;
      font-weight: normal;
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
    ul { padding-left: 1.2em; padding-right: 1.2em; }
    li { margin-bottom: 0.4em; }
    section { margin-bottom: 1.4em; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 0.8em;
    }
    th, td {
      border: 1px solid #cccccc;
      padding: 6px 8px;
      font-size: 0.92rem;
      text-align: left;
    }
    a {
      color: white;
      text-decoration: none;
    }
    th { background: #8C9EFF99; color: white; }
    strong { color: #8C9EFF99; }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p><em>$effectiveDate</em></p>

  <section>
    <h2>1. $acceptanceTitle</h2>
    <p>$acceptanceContent</p>
  </section>

  <section>
    <h2>2. $eligibilityTitle</h2>
    <p>$eligibilityContent</p>
  </section>

  <section>
    <h2>3. $accountsTitle</h2>
    <p>$accountsContent</p>
  </section>

  <section>
    <h2>4. $gameplayTitle</h2>
    <ul>
      <li>$gameplayRule1</li>
      <li>$gameplayRule2</li>
      <li>$gameplayRule3</li>
    </ul>
  </section>

  <section>
    <h2>5. $virtualCurrencyTitle</h2>
    <p>$virtualCurrencyContent</p>
  </section>

  <section>
    <h2>6. $subscriptionsTitle</h2>
    <table>
      <thead>
        <tr><th>$productHeader</th><th>$priceHeader</th><th>$billingHeader</th></tr>
      </thead>
      <tbody>
        <tr><td>$premium1Month</td><td>US \$4.99</td><td>$renewsMonthly</td></tr>
        <tr><td>$premium3Months</td><td>US \$9.99</td><td>$renews3Months</td></tr>
        <tr><td>$premium12Months</td><td>US \$29.99</td><td>$renewsAnnually</td></tr>
        <tr><td>$coins100</td><td>US \$0.99</td><td>$oneTime</td></tr>
        <tr><td>$coins500</td><td>US \$3.99</td><td>$oneTime</td></tr>
        <tr><td>$coins1200</td><td>US \$7.99</td><td>$oneTime</td></tr>
        <tr><td>$coins2500</td><td>US \$14.99</td><td>$oneTime</td></tr>
      </tbody>
    </table>
    <p>$subscriptionsNote</p>
  </section>

  <section>
    <h2>7. $advertisingTitle</h2>
    <p>$advertisingContent</p>
  </section>

  <section>
    <h2>8. $privacyTitle</h2>
    <p>$privacyContent</p>
  </section>

  <section>
    <h2>9. $intellectualTitle</h2>
    <p>$intellectualContent</p>
  </section>

  <section>
    <h2>10. $disclaimerTitle</h2>
    <p>$disclaimerContent</p>
  </section>

  <section>
    <h2>11. $limitationTitle</h2>
    <p>$limitationContent</p>
  </section>

  <section>
    <h2>12. $terminationTitle</h2>
    <p>$terminationContent</p>
  </section>

  <section>
    <h2>13. $contactTitle</h2>
    <p>$contactContent</p>
  </section>

  <p><em>$finalNote</em></p>
</body>
</html>
''';
  }
}
