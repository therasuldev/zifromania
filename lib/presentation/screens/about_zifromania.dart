import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        leading: const CustomBackButton(),
        elevation: 0,
        title: const Text(
          'About ZifroMania',
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
<html lang="az">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZifroMania haqqında</title>

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
    ul { padding-left: 1.2em; }
    li { margin-bottom: 0.4em; }
    section { margin-bottom: 1.4em; }
  </style>
</head>
<body>
  <h1>ZifroMania haqqında</h1>

  <section>
    <p>ZifroMania riyazi hesablamanı oyunlaşdıraraq sürətinizi, diqqətinizi və məntiqinizi eyni anda inkişaf etdirən mobil tətbiqdir. Burada beş fərqli kateqoriya mövcuddur, hər biri özünəməxsus tempo və çətinlik səviyyəsi ilə:</p>
    <ul>
      <li><strong>Speed Calculation</strong> – 60 saniyədə maksimum sayda düzgün cavab toplayın, xallar qazanın.</li>
      <li><strong>Multiplication Table</strong> – 1‑dən 10‑a qədər vurma və bölmə məşqləri; 50‑dən çox düzgün cavabla "Master" nişanını qazanmaq fürsəti.</li>
      <li><strong>True or False</strong> – Hər suala cəmi 3 saniyə vaxt; reflekslərinizi sınağa çəkin.</li>
      <li><strong>Expert Mode</strong> – 120 saniyəlik çağırışda daha mürəkkəb əməliyyatlarla gücünüzü sınayın; 60+ düzgün cavabla "Master" statusu.</li>
      <li><strong>Training Mode</strong> – Vaxt məhdudiyyəti olmadan 50 suallıq sessiyalarla sərbəst məşq edin.</li>
    </ul>
  </section>

  <section>
    <h2>Coinlər və nailiyyətlər</h2>
    <ul>
      <li>Hər gün pulsuz coin bonusu əldə edin.</li>
      <li>Reklam izləməklə əlavə coin qazanma imkanı mövcuddur.</li>
      <li>Coinlər vasitəsilə kateqoriya limitlərini qaldırın, çətinlikləri açın və fərdi rekordu yeniləyin.</li>
      <li>Qazandığınız nailiyyətləri izləyin və sosial şəbəkələrdə paylaşın!</li>
    </ul>
  </section>

  <section>
    <h2>Premium abunəlik</h2>
    <p>Reklamsız təcrübə və genişləndirilmiş günlük limitlər üçün Premium seçin:</p>
    <ul>
      <li>1 ay – 4,99 \$</li>
      <li>3 ay – 9,99 \$</li>
      <li>12 ay – 29,99 \$</li>
    </ul>
  </section>

  <section>
    <h2>Coin paketləri</h2>
    <ul>
      <li>100 coin – 0,99 \$</li>
      <li>500 (+50 bonus) – 3,99 \$</li>
      <li>1200 (+200 bonus) – 7,99 \$</li>
      <li>2500 (+500 bonus) – 14,99 \$</li>
    </ul>
  </section>

  <p>ZifroMania ilə riyaziyyat daha əyləncəli və həyəcanlıdır. İndi qoşulun, bacarıqlarınızı artırın və rəqəmlərin dünyasında zirvəyə qalxın!</p>
</body>
</html>''';
  }
}
