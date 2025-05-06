import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
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

  Future<void> _initWebView() async {
    // Load font as base64
    final fontBytes = await rootBundle.load('assets/fonts/Scabber.ttf');
    final fontBase64 = base64Encode(fontBytes.buffer.asUint8List());

    // Create HTML with embedded font
    _htmlContent = _getHtmlWithEmbeddedFont(fontBase64);

    // Setup WebView controller
    _controller = WebViewController()
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        leading: const CustomBackButton(),
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontFamily: 'Scabber', fontSize: 22, color: Colors.black54),
        ),
      ),
      body: Stack(
        children: [
          if (!_isLoading && _htmlContent.isNotEmpty) WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Creates HTML string with the font embedded as base64
  String _getHtmlWithEmbeddedFont(String fontBase64) {
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Privacy Policy</title>

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
      background: #fafafa;
      color: #0000008A;
    }
    h1 { 
      font-size: 1.8rem; 
      margin-top: 0; 
      color: #4b8dc2;
    }
    h2 { 
      font-size: 1.4rem; 
      margin-top: 1.4em; 
      color: #4b8dc2;
    }
    ul { 
      padding-left: 1.2em; 
    }
    li { 
      margin-bottom: 0.4em; 
    }
    section { 
      margin-bottom: 1.8em; 
      background: white;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    strong {
      color: #4b8dc2;
    }
    a {
      color: #4b8dc2;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    .email {
      font-weight: bold;
    }
  </style>
</head>
<body>
  <h1>Privacy Policy</h1>

  <section>
    <h2>1. Introduction</h2>
    <p>Welcome to ZifroMania ("the App"). We are dedicated to protecting your privacy and ensuring that your personal information is handled responsibly. This Privacy Policy outlines how we collect, use, and safeguard your data.</p>
  </section>

  <section>
    <h2>2. Information We Collect</h2>
    <p>The App may collect the following types of information:</p>
    <ul>
      <li><strong>Device Information</strong>: Such as device model, operating system version, and usage patterns within the app.</li>
      <li><strong>User Information</strong>: Including data generated during advertising interactions and in-app purchases.</li>
    </ul>
  </section>

  <section>
    <h2>3. How We Use Your Information</h2>
    <p>We use the information collected to:</p>
    <ul>
      <li>Enhance the functionality and overall user experience of the App.</li>
      <li>Provide personalized and relevant advertisements.</li>
      <li>Process and manage in-app purchases efficiently.</li>
    </ul>
  </section>

  <section>
    <h2>4. Third-Party Services</h2>
    <p>We utilize the following third-party services:</p>
    <ul>
      <li><strong>Google AdMob</strong>: For delivering advertisements. Refer to Google's Privacy Policy for further details: <a href="https://policies.google.com/privacy">https://policies.google.com/privacy</a></li>
      <li><strong>Google Play Billing</strong>: For managing and processing in-app purchases securely.</li>
    </ul>
  </section>

  <section>
    <h2>5. Data Security</h2>
    <p>We implement industry-standard security measures to protect your personal information and ensure it is stored securely.</p>
  </section>

  <section>
    <h2>6. Children's Privacy</h2>
    <p>The App is not intended for users under the age of 13, and we do not knowingly collect personal data from children. If you believe that we may have collected such information, please contact us immediately.</p>
  </section>

  <section>
    <h2>7. Changes to This Privacy Policy</h2>
    <p>We may update this Privacy Policy periodically. Users will be informed of any changes through notifications within the App.</p>
  </section>

  <section>
    <h2>8. Contact Us</h2>
    <p>If you have questions or concerns regarding this Privacy Policy, please contact us at:</p>
    <p>Email: <span class="email">rasul.ramixanov@gmail.com</span></p>
  </section>

</body>
</html>''';
  }
}
