import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/errors/app_exception.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_action_notifier.dart';
import 'package:zifromania/features/auth/presentation/widgets/sign_in_button.dart';
import 'package:zifromania/core/router/route_names.dart';

/// Sign-in screen with mandatory Terms of Service acceptance.
/// The Google button stays disabled until the checkbox is ticked.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  static const _horizontalPadding = 32.0;

  static const _titleStyle = TextStyle(
    fontSize: 50,
    fontFamily: 'Brawler',
    fontWeight: FontWeight.bold,
    color: Colors.white70,
  );

  static const _subtitleStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Scabber',
    color: Colors.white38,
  );

  static const _termsTextStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontFamily: 'Scabber',
    color: Colors.white70,
  );

  static const _linkStyle = TextStyle(
    decoration: TextDecoration.underline,
    color: Colors.blue,
  );

  bool _acceptedTerms = false;

  Future<void> _handleGoogleSignIn() async {
    final error = await ref.read(authActionNotifierProvider.notifier).signInWithGoogle();

    if (!mounted || error == null) return;

    _showErrorSnackBar(error);
  }

  void _showErrorSnackBar(AppException error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authActionNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/scaffold.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Stack(
                children: [
                  _MainContent(
                    acceptedTerms: _acceptedTerms,
                    onTermsChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                    onGoogleSignIn: _handleGoogleSignIn,
                    titleStyle: _titleStyle,
                    subtitleStyle: _subtitleStyle,
                    termsTextStyle: _termsTextStyle,
                    linkStyle: _linkStyle,
                  ),
                  if (isLoading) const _LoadingOverlay(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.onGoogleSignIn,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.termsTextStyle,
    required this.linkStyle,
  });

  final bool acceptedTerms;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onGoogleSignIn;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle termsTextStyle;
  final TextStyle linkStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        const Center(
          child: _FadedLogo(),
        ),
        const SizedBox(height: 32),
        Text(
          'ZifroMania',
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        const SizedBox(height: 16),
        Text(
          'auth.sign_in_prompt'.tr(),
          textAlign: TextAlign.center,
          style: subtitleStyle,
        ),
        const Spacer(flex: 2),
        SignInButton(
          text: 'auth.continue_with_google'.tr(),
          iconPath: 'assets/icons/google.png',
          enabled: acceptedTerms,
          onTap: onGoogleSignIn,
        ),
        const SizedBox(height: 16),
        _TermsRow(
          accepted: acceptedTerms,
          onChanged: onTermsChanged,
          textStyle: termsTextStyle,
          linkStyle: linkStyle,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// App logo with a radial fade-to-transparent effect at the edges.
class _FadedLogo extends StatelessWidget {
  const _FadedLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const RadialGradient(
          center: Alignment.center,
          radius: 0.55,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0.6, 0.6, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        'assets/images/zifromania.png',
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Checkbox + "I agree to Terms & Privacy Policy" text row.
class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.accepted,
    required this.onChanged,
    required this.textStyle,
    required this.linkStyle,
  });

  final bool accepted;
  final ValueChanged<bool?> onChanged;
  final TextStyle textStyle;
  final TextStyle linkStyle;

  // RegExp is required here because the placeholders are matched by pattern.
  // ignore: deprecated_member_use
  static final Pattern _placeholderPattern = RegExp(r'\[\[(TERMS|PRIVACY)\]\]');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          fillColor: WidgetStateProperty.all(Colors.white),
          checkColor: Colors.green,
          value: accepted,
          onChanged: onChanged,
        ),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textStyle,
              children: _buildTermsSpans(context),
            ),
          ),
        ),
      ],
    );
  }

  List<InlineSpan> _buildTermsSpans(BuildContext context) {
    final template = 'auth.termsCombined'
        .tr()
        .replaceAll('{terms}', '[[TERMS]]')
        .replaceAll('{privacy}', '[[PRIVACY]]');

    final spans = <InlineSpan>[];

    template.splitMapJoin(
      _placeholderPattern,
      onMatch: (match) {
        spans.add(
          _buildLink(
            context,
            match.group(1)!,
          ),
        );

        return '';
      },
      onNonMatch: (text) {
        spans.add(
          TextSpan(text: text),
        );

        return '';
      },
    );

    return spans;
  }

  TextSpan _buildLink(
    BuildContext context,
    String type,
  ) {
    final isTerms = type == 'TERMS';

    return TextSpan(
      text: isTerms ? 'auth.termsOfService'.tr() : 'auth.privacyPolicy'.tr(),
      style: linkStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          context.push(
            isTerms ? RouteNames.terms : RouteNames.privacy,
          );
        },
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(64),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CupertinoActivityIndicator(
          radius: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
