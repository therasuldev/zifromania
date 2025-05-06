import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
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
  <title>ZifroMania – İstifadə Şərtləri</title>

  <style>
    @font-face {
      font-family: 'Scabber';
      src: url(data:font/truetype;charset=utf-8;base64,$fontBase64) format('truetype');      font-style: normal;
      font-weight: normal;
    }

    body {
      font-family: 'Scabber', -apple-system, BlinkMacSystemFont, 'Segoe UI',
                   Roboto, Helvetica, Arial, sans-serif;
      margin: 0;
      padding: 16px;
      line-height: 1.6;
      background: #fafafa;
      color: #000000d9;
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
    th { background: #e7f1fb; }
  </style>
</head>
<body>
  <h1>ZifroMania – İstifadə Şərtləri (Terms of Service)</h1>
  <p><em>Qüvvəyə minmə tarixi: 07 May 2025</em></p>

  <section>
    <h2>1. Şərtlərin Qəbulu</h2>
    <p>ZifroMania mobil tətbiqini (“Tətbiq”) quraşdırmaq və ya istifadə etmək
       bu İstifadə Şərtlərini (“Şərtlər”) və Məxfilik Siyasətimizi qəbul
       etdiyiniz anlamına gəlir. Şirkət (“ZifroMania LLC”) Şərtləri istənilən
       vaxt yeniləyə bilər; yenilənmiş versiya bu səhifədə dərc edildiyi andan
       qüvvəyə minir.</p>
  </section>

  <section>
    <h2>2. Yaş Məhdudiyyəti</h2>
    <p>Tətbiqdən istifadə etmək üçün ən azı 13&nbsp;yaş (bəzi regionlarda
       16&nbsp;yaş) olmalıdır. Valideyn icazəsi olmadan bu yaşdan kiçik
       şəxslərin xidmətə qoşulması qadağandır.</p>
  </section>

  <section>
    <h2>3. Hesablar və Giriş</h2>
    <p>Tətbiqə Google, Apple, e‑poçt və ya anonim qonaq girişi ilə daxil ola
       bilərsiniz. Hesabınızın təhlükəsizliyinə görə yalnız siz cavabdehsiniz.
       Başqasının hesabından icazəsiz istifadə qadağandır.</p>
  </section>

  <section>
    <h2>4. Oyun Qaydaları və Qadağan Olunan Davranış</h2>
    <ul>
      <li>Avtomatlaşdırılmış skript, bot və ya hər hansı hack alətindən
          istifadə etmək qadağandır.</li>
      <li>Tətbiqin kodunu tərs mühəndislik etmək və ya dəyişdirmək
          qadağandır.</li>
      <li>Qayda pozuntusu aşkarlandıqda hesab xəbərdarlıq etmədən bloklana və
          ya silinə bilər.</li>
    </ul>
  </section>

  <section>
    <h2>5. Virtual Valyuta (Coinlər)</h2>
    <p>Coinlər yalnız Tətbiqdaxili funksiyalar üçün nəzərdə tutulub, real
       maliyyə dəyəri yoxdur və üçüncü tərəfə köçürülə bilməz. ZifroMania LLC
       coin balansını, qazanma üsullarını və qiymətlərini istənilən vaxt
       dəyişmək hüququnu saxlayır.</p>
  </section>

  <section>
    <h2>6. Abunə və Daxili Satışlar</h2>
    <table>
      <thead>
        <tr><th>Məhsul</th><th>Qiymət</th><th>Dövrilik</th></tr>
      </thead>
      <tbody>
        <tr><td>Premium (1 ay)</td><td>4,99&nbsp;\$</td><td>Aylıq yenilənir</td></tr>
        <tr><td>Premium (3 ay)</td><td>9,99&nbsp;\$</td><td>3 aydan bir</td></tr>
        <tr><td>Premium (12 ay)</td><td>29,99&nbsp;\$</td><td>İllik</td></tr>
        <tr><td>100 coin</td><td>0,99&nbsp;\$</td><td>Birdəfəlik</td></tr>
        <tr><td>500 coin + 50 bonus</td><td>3,99&nbsp;\$</td><td>Birdəfəlik</td></tr>
        <tr><td>1200 coin + 200 bonus</td><td>7,99&nbsp;\$</td><td>Birdəfəlik</td></tr>
        <tr><td>2500 coin + 500 bonus</td><td>14,99&nbsp;\$</td><td>Birdəfəlik</td></tr>
      </tbody>
    </table>
    <p>Ödənişlər Google Play və ya App Store hesabınız vasitəsilə emal olunur.
       Abunəni istənilən vaxt mağaza hesab parametrlərinizdən ləğv edə
       bilərsiniz. Virtual coin alışı və istifadə olunmuş abunə müddəti üzrə
       ödənişlər geri qaytarılmır (qanunla tələb olunmadıqca).</p>
  </section>

  <section>
    <h2>7. Reklam və Analitika</h2>
    <p>Pulsuz istifadəçilərə reklam göstərilə bilər. Tətbiq Google AdMob,
       Firebase Analytics və oxşar xidmətlərdən istifadə edərək cihaz
       məlumatlarını toplaya bilər. Ətraflı məlumat üçün Məxfilik Siyasətinə
       baxın.</p>
  </section>

  <section>
    <h2>8. Məxfilik</h2>
    <p>Şəxsi məlumatların toplanması, saxlanması və işlənməsi qaydaları
       Məxfilik Siyasətimizdə ətraflı izah edilir. Tətbiqdən istifadə etməklə
       həmin siyasətlə də razılaşırsınız.</p>
  </section>

  <section>
    <h2>9. İntellektual Mülkiyyət</h2>
    <p>Tətbiq, loqo, məzmun, sual bazası, qrafika və kod daxil olmaqla bütün
       materiallar ZifroMania LLC‑yə məxsusdur. Yazılı icazə olmadan
       kopyalanması, yayılması və ya dəyişdirilməsi qadağandır.</p>
  </section>

  <section>
    <h2>10. Zəmanət İmtinası</h2>
    <p>Tətbiq “olduğu kimi” təqdim edilir. ZifroMania LLC Tətbiqin fasiləsiz,
       xətasız və ya təhlükəsiz işləyəcəyinə dair heç bir zəmanət vermir.</p>
  </section>

  <section>
    <h2>11. Məsuliyyətin Məhdudlaşdırılması</h2>
    <p>Qanunla icazə verilən maksimum həddə qədər ZifroMania LLC Tətbiqdən
       istifadə nəticəsində yaranan dolayı, təsadüfi və ya xüsusi zərərlərə
       görə məsuliyyət daşımır.</p>
  </section>

  <section>
    <h2>12. Ləğv</h2>
    <p>Siz istənilən vaxt Tətbiqi silərək bu Şərtləri dayandıra bilərsiniz.
       Qayda pozuntusu olduqda biz hesabınızı xəbərdarlıq etmədən ləğv edə
       və ya girişinizi məhdudlaşdıra bilərik.</p>
  </section>

  <section>
    <h2>13. Qanun və Mübahisələrin Həlli</h2>
    <p>Bu Şərtlər Azərbaycan Respublikasının qanunlarına uyğun tənzimlənir.
       Mübahisələr Bakı şəhər məhkəmələrində həll edilir.</p>
  </section>

  <section>
    <h2>14. Əlaqə</h2>
    <p>Suallar, şikayətlər və ya geribildirim üçün: <a href="mailto:rasul.ramixanov@gmail.com">support@zifromania.app</a></p>
  </section>

  <p><em>Bu səhifəni oxuyub davam etməklə yuxarıdakı bütün şərtlərlə
     razılaşmış olursunuz.</em></p>
</body>
</html>
''';
  }
}
