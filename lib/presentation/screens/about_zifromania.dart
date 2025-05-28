import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'dart:convert';

import 'package:zifromania/presentation/common/back_button.dart';

class AboutZifroManiaScreen extends StatefulWidget {
  const AboutZifroManiaScreen({super.key});

  @override
  State<AboutZifroManiaScreen> createState() => _AboutZifroManiaScreenState();
}

class _AboutZifroManiaScreenState extends State<AboutZifroManiaScreen> {
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
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'About ZifroMania',
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

  /// Creates HTML string with the font embedded as base64 (EN version)
  String _getHtmlWithEmbeddedFont(String fontBase64) {
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>About ZifroMania</title>

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
    ul { padding-left: 1.2em; }
    li { margin-bottom: 0.4em; }
    section { margin-bottom: 1.4em; }
  </style>
</head>
<body>
  <h1>About ZifroMania</h1>

  <section>
    <p>
      <strong>ZifroMania</strong> turns mental math into an engaging game,
      helping you sharpen speed, focus, and logic all at once. Five carefully
      crafted categories let players of every age and skill level progress at
      their own pace:
    </p>
    <ul>
      <li><strong>Speed Calculation</strong> – Answer as many questions as possible in 60 seconds and rack up points.</li>
      <li><strong>Multiplication Table</strong> – Master 1-to-10 multiplication and division; 50+ correct answers grant the “Master” badge.</li>
      <li><strong>True or False</strong> – Decide in just 3 seconds per prompt; perfect for reflex training.</li>
      <li><strong>Expert Mode</strong> – A 120-second challenge featuring advanced operators; 60+ correct answers earn “Master” status.</li>
      <li><strong>Training Mode</strong> – Unlimited time, 50 questions per session—practice with zero pressure.</li>
    </ul>
  </section>

  <section>
    <h2>Coins & Achievements</h2>
    <ul>
      <li>Collect a free daily coin bonus.</li>
      <li>Watch optional ads to earn extra coins.</li>
      <li>Spend coins to lift category limits, unlock higher difficulties, and chase new personal bests.</li>
      <li>Track your achievements and share them on social media.</li>
    </ul>
  </section>

  <section>
    <h2>Premium Subscription</h2>
    <p>Enjoy an ad-free experience and extended daily limits:</p>
    <ul>
      <li>1 month – US \$4.99</li>
      <li>3 months – US \$9.99</li>
      <li>12 months – US \$29.99</li>
    </ul>
  </section>

  <section>
    <h2>Coin Bundles</h2>
    <ul>
      <li>100 coins – US \$0.99</li>
      <li>500 coins + 50 bonus – US \$3.99</li>
      <li>1 200 coins + 200 bonus – US \$7.99</li>
      <li>2 500 coins + 500 bonus – US \$14.99</li>
    </ul>
  </section>

  <p>
    With ZifroMania, mathematics becomes fun, fast, and competitive. Join now,
    level up your skills, and reach the top of the leaderboard in the wonderful
    world of numbers!
  </p>
</body>
</html>
''';
  }
}
