import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zifromania/presentation/common/partial_modal_route.dart';
import 'package:zifromania/presentation/screens/privacy_policy.dart';
import 'package:zifromania/presentation/screens/terms_of_service.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_event.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_state.dart';

/// Sign‑in screen with mandatory Terms of Service acceptance.
/// Google button remains disabled (greyed‑out) until the checkbox is ticked.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const _horizontalPadding = 32.0;
  static const _buttonHeight = 56.0;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        builder: (ctx, state) {
          final isLoading = _isLoadingState(state);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                'assets/images/scaffold.jpg',
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AuthScreen._horizontalPadding),
                  child: Stack(
                    children: [
                      _buildMainContent(ctx),
                      if (isLoading) _buildLoadingOverlay(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* ───────────────────────── Helpers ───────────────────────── */

  void _onAuthStateChanged(BuildContext ctx, AuthState state) {
    if (state.event == AuthEvents.googleSignInRequestedError) {
      final msg = state.error ?? 'auth.google_sign_in_cancelled'.tr();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  bool _isLoadingState(AuthState state) => state.event == AuthEvents.googleSignInRequested;

  /* ───────────────────────── UI ───────────────────────── */

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        Center(child: _buildLogoWithFullFade()),
        const SizedBox(height: 32),
        _buildTitle(),
        const SizedBox(height: 16),
        _buildSubtitle(),
        const Spacer(flex: 2),
        _buildGoogleButton(context),
        const SizedBox(height: 16),
        _buildTermsRow(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLogoWithFullFade() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const RadialGradient(
          center: Alignment.center,
          radius: 0.55,
          colors: [
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
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

  Widget _buildTitle() => const Text(
        'ZifroMania',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 50,
          fontFamily: 'Brawler',
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      );

  Widget _buildSubtitle() => Text(
        'auth.sign_in_prompt'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Scabber',
          color: Colors.white38,
        ),
      );

  Widget _buildGoogleButton(BuildContext context) {
    return SignInButton(
      text: 'auth.continue_with_google'.tr(),
      iconpath: 'assets/icons/google.png',
      backgroundColor: _acceptedTerms ? Colors.white : Colors.white60,
      textColor: _acceptedTerms ? Colors.black87 : Colors.white,
      borderColor: _acceptedTerms ? Colors.grey.shade300 : Colors.grey.shade400,
      enabled: _acceptedTerms,
      onTap: () => context.read<AuthBloc>().add(AuthEvent.googleSignInRequested()),
    );
  }

  Widget _buildTermsRow(BuildContext context) {
    final termsText = 'auth.termsOfService'.tr();
    final privacyText = 'auth.privacyPolicy'.tr();

    final fullText = 'auth.termsCombined'.tr().replaceAll('{terms}', '[[TERMS]]').replaceAll('{privacy}', '[[PRIVACY]]');

    final List<InlineSpan> spans = [];

    fullText.splitMapJoin(
      RegExp(r'\[\[(TERMS|PRIVACY)\]\]'),
      onMatch: (match) {
        final type = match.group(1);
        if (type == 'TERMS') {
          spans.add(TextSpan(
            text: termsText,
            style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                    context,
                    PartialModalRoute(child: const TermsOfServiceScreen()),
                  ),
          ));
        } else {
          spans.add(TextSpan(
            text: privacyText,
            style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                    context,
                    PartialModalRoute(child: const PrivacyPolicyScreen()),
                  ),
          ));
        }
        return '';
      },
      onNonMatch: (text) {
        spans.add(TextSpan(text: text));
        return '';
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          fillColor: WidgetStateProperty.all(Colors.white),
          checkColor: Colors.green,
          value: _acceptedTerms,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
        ),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Scabber',
                color: Colors.white70,
              ),
              children: spans,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() => Center(
        child: Container(
          padding: const EdgeInsets.all(64),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const CupertinoActivityIndicator(radius: 16, color: Colors.white),
        ),
      );
}

/* ───────────────────────── SignInButton ───────────────────────── */

class SignInButton extends StatelessWidget {
  final String text;
  final String? iconpath;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool enabled;

  const SignInButton({
    super.key,
    required this.text,
    this.icon,
    this.iconpath,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.onTap,
    this.enabled = true,
  }) : assert(icon != null || iconpath != null, 'Either icon or iconpath must be provided');

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: AuthScreen._buttonHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: enabled ? 0.05 : 0.02),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) icon!,
              if (iconpath != null) Image.asset(iconpath!, height: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Scabber',
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
