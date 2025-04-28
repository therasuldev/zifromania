// lib/presentation/screens/signin_screen.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_bloc.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_event.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_state.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state.event == AuthEvents.authError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.error.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (ctx, state) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      Center(child: Image.asset('assets/icons/algebra.png', height: 180)),
                      const SizedBox(height: 32),
                      Text(
                        'Equation Quest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'Brawler',
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sign in to continue your math adventure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'rimouskisb',
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(flex: 2),
                      SignInButton(
                        text: 'Continue with Google',
                        iconpath: 'assets/icons/google.png',
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        borderColor: Colors.grey.shade300,
                        onTap: () => context.read<AuthBloc>().add(AuthEvent.googleSignInRequested()),
                      ),
                      const SizedBox(height: 16),
                      if (Platform.isIOS)
                        SignInButton(
                          text: 'Continue with Apple',
                          icon: Icon(Icons.apple, color: Colors.white, size: 32),
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          borderColor: Colors.transparent,
                          onTap: () => context.read<AuthBloc>().add(AuthEvent.appleSignInRequested()),
                        ),
                      if (Platform.isIOS) const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          'By signing in, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'rimouskisb',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.event == AuthEvents.googleSignInRequested || state.event == AuthEvents.appleSignInRequested)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(64),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const CupertinoActivityIndicator(color: Colors.white, radius: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final String text;
  final String? iconpath;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const SignInButton({
    super.key,
    required this.text,
    this.icon,
    this.iconpath,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.onTap,
  }) : assert(icon != null || iconpath != null, 'Either icon or iconpath must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
    );
  }
}
