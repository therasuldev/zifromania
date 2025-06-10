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
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AuthScreen._horizontalPadding),
              child: Stack(
                children: [
                  _buildMainContent(ctx),
                  if (isLoading) _buildLoadingOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* ───────────────────────── Helpers ───────────────────────── */

  void _onAuthStateChanged(BuildContext ctx, AuthState state) {
    if (state.event == AuthEvents.googleSignInRequestedError) {
      final msg = state.error ?? 'Google sign‑in was cancelled';
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
        Center(child: Image.asset('assets/images/zifromania.png', height: 180)),
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

  Widget _buildTitle() => Text(
        'Zifromania',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 50,
          fontFamily: 'Brawler',
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      );

  Widget _buildSubtitle() => Text(
        'Sign in to continue your math adventure',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'RimouskisB',
          color: Colors.grey.shade600,
        ),
      );

  Widget _buildGoogleButton(BuildContext context) {
    return SignInButton(
      text: 'Continue with Google',
      iconpath: 'assets/icons/google.png',
      backgroundColor: _acceptedTerms ? Colors.white : Colors.grey.shade200,
      textColor: _acceptedTerms ? Colors.black87 : Colors.grey,
      borderColor: _acceptedTerms ? Colors.grey.shade300 : Colors.grey.shade400,
      enabled: _acceptedTerms,
      onTap: () => context.read<AuthBloc>().add(AuthEvent.googleSignInRequested()),
    );
  }

  Widget _buildTermsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
        ),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 12, fontFamily: 'RimouskisB', color: Colors.grey.shade600),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          PartialModalRoute(child: const TermsOfServiceScreen()),
                        ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          PartialModalRoute(child: const PrivacyPolicyScreen()),
                        ),
                ),
              ],
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
                  fontFamily: 'rimouskisb',
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
