import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'dart:convert';

import 'package:zifromania/presentation/common/back_button.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _htmlContent = ''; // Will store full HTML with embedded font

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Load font as base64
    final fontBytes = await rootBundle.load('assets/fonts/Scabber.ttf');
    final fontBase64 = base64Encode(fontBytes.buffer.asUint8List());

    // Create HTML with embedded font
    _htmlContent = _getHtmlWithEmbeddedFont(fontBase64);

    // Setup WebView controller
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
          'Terms of Service',
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

  /// Creates HTML string with the font embedded as base64 (EN version,
  /// no age restriction, Google + e-mail login only, no “Law & Disputes” section)
  String _getHtmlWithEmbeddedFont(String fontBase64) {
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZifroMania – Terms of Service</title>

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
  </style>
</head>
<body>
  <h1>ZifroMania – Terms of Service</h1>
  <p><em>Effective date: 07 May 2025</em></p>

  <section>
    <h2>1. Acceptance of Terms</h2>
    <p>
      By installing or using the ZifroMania mobile application (the “App”),
      you agree to these Terms of Service (“Terms”) and to our Privacy Policy.
      ZifroMania LLC (“Company”, “we”, “us”) may revise the Terms at any time;
      the revised version becomes effective once posted on this page.
    </p>
  </section>

  <section>
    <h2>2. Eligibility</h2>
    <p>
      The App is suitable for <strong>all age groups</strong>. If you are a
      minor in your jurisdiction (typically under 18 years old), please obtain
      permission from a parent or legal guardian before making any in-app
      purchases.
    </p>
  </section>

  <section>
    <h2>3. Accounts and Access</h2>
    <p>
      You may access the App via Google Sign-In or by creating an
      e-mail-and-password account through Firebase Authentication. You are
      responsible for safeguarding your credentials and for all activity that
      occurs under your account. Using another person’s account without
      authorization is prohibited.
    </p>
  </section>

  <section>
    <h2>4. Gameplay Rules and Prohibited Conduct</h2>
    <ul>
      <li>Automated scripts, bots, emulators, or hacking tools are prohibited.</li>
      <li>Reverse-engineering, decompiling, or modifying the App’s code is not allowed.</li>
      <li>Accounts violating these rules may be suspended or terminated without notice.</li>
    </ul>
  </section>

  <section>
    <h2>5. Virtual Currency (Coins)</h2>
    <p>
      Coins are a virtual currency usable only within the App. They have no
      real-world monetary value and cannot be transferred to other accounts or
      third parties. ZifroMania LLC reserves the right to change coin balances,
      earning methods, and pricing at any time.
    </p>
  </section>

  <section>
    <h2>6. Subscriptions and In-App Purchases</h2>
    <table>
      <thead>
        <tr><th>Product</th><th>Price</th><th>Billing Cycle</th></tr>
      </thead>
      <tbody>
        <tr><td>Premium (1 month)</td><td>US \$4.99</td><td>Renews monthly</td></tr>
        <tr><td>Premium (3 months)</td><td>US \$9.99</td><td>Renews every 3 months</td></tr>
        <tr><td>Premium (12 months)</td><td>US \$29.99</td><td>Renews annually</td></tr>
        <tr><td>100 Coins</td><td>US \$0.99</td><td>One-time</td></tr>
        <tr><td>500 Coins + 50 bonus</td><td>US \$3.99</td><td>One-time</td></tr>
        <tr><td>1 200 Coins + 200 bonus</td><td>US \$7.99</td><td>One-time</td></tr>
        <tr><td>2 500 Coins + 500 bonus</td><td>US \$14.99</td><td>One-time</td></tr>
      </tbody>
    </table>
    <p>
      Payments are processed through your Google Play account. Subscriptions may
      be cancelled at any time via Google Play settings. Except where required
      by law, purchases of virtual coins or partially used subscription periods
      are non-refundable.
    </p>
  </section>

  <section>
    <h2>7. Advertising and Analytics</h2>
    <p>
      The free tier of the App may display advertisements. The App uses
      Google AdMob, Firebase Analytics, and similar services, which may collect
      device information in accordance with our Privacy Policy.
    </p>
  </section>

  <section>
    <h2>8. Privacy</h2>
    <p>
      Our practices regarding the collection, storage, and processing of
      personal data are detailed in our Privacy Policy. By using the App, you
      also agree to that policy.
    </p>
  </section>

  <section>
    <h2>9. Intellectual Property</h2>
    <p>
      All materials in the App—including software, logo, content, question
      database, graphics, and code—are the property of ZifroMania LLC and may
      not be copied, distributed, or modified without our prior written consent.
    </p>
  </section>

  <section>
    <h2>10. Disclaimer of Warranties</h2>
    <p>
      The App is provided “as is”. ZifroMania LLC makes no warranties that the
      App will be uninterrupted, error-free, or secure.
    </p>
  </section>

  <section>
    <h2>11. Limitation of Liability</h2>
    <p>
      To the maximum extent permitted by law, ZifroMania LLC shall not be liable
      for any indirect, incidental, special, or consequential damages arising
      out of or in connection with your use of the App.
    </p>
  </section>

  <section>
    <h2>12. Termination</h2>
    <p>
      You may terminate these Terms at any time by uninstalling the App. We may
      suspend or terminate your account without notice if we reasonably believe
      you have violated these Terms.
    </p>
  </section>

  <section>
    <h2>13. Contact</h2>
    <p>
      If you have any questions, complaints, or feedback, please email us at
      <a href="mailto:rasul.ramixanov@gmail.com">rasul.ramixanov@gmail.com</a>.
    </p>
  </section>

  <p>
    <em>By continuing to use the App, you acknowledge that you have read and
    agree to all of the above Terms.</em>
  </p>
</body>
</html>
''';
  }
}
