import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/router/route_names.dart';
import 'package:zifromania/core/widgets/versionarte_gate.dart';
import 'package:zifromania/shared/constants/app_constants.dart';
import 'package:zifromania/features/game_usage/domain/entities/game_category.dart';
import 'package:zifromania/features/auth/presentation/pages/auth_screen.dart';
import 'package:zifromania/features/auth/presentation/pages/splash_screen.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zifromania/features/game_usage/presentation/pages/game_intro_screen.dart';
import 'package:zifromania/features/purchase/presentation/enum/tab_type.dart';
import 'package:zifromania/features/rank/presentation/pages/leaderboard_screen.dart';
import 'package:zifromania/features/settings/presentation/pages/about_zifromania.dart';
import 'package:zifromania/features/settings/presentation/pages/feedback_screen.dart';
import 'package:zifromania/features/settings/presentation/pages/privacy_policy.dart';
import 'package:zifromania/features/settings/presentation/pages/settings_screen.dart';
import 'package:zifromania/features/settings/presentation/pages/terms_of_service.dart';
import 'package:zifromania/features/title/presentation/pages/achievements_screen.dart';
import 'package:zifromania/features/game_usage/presentation/pages/game_screen.dart';
import 'package:zifromania/features/purchase/presentation/pages/subscription_screen.dart';

/// Routes that can be opened without being authenticated.
const _publicRoutes = <String>{
  RouteNames.splash,
  RouteNames.login,
  RouteNames.terms,
  RouteNames.privacy,
  // RouteNames.about,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      final location = state.uri.path;
      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;
      final isPublic = _publicRoutes.contains(location);

      // Only wait for the initial authentication check.
      if (authState.isLoading) {
        return isSplash ? null : RouteNames.splash;
      }

      // Authenticated user should not stay on login.
      if (authState.value != null && isLogin) {
        return RouteNames.home;
      }

      // Unauthenticated user can only access public routes.
      if (authState.value == null && !isPublic) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const VersionarteGate(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const GameIntroScreen(),
      ),
      GoRoute(
        path: '${RouteNames.game}/:category',
        pageBuilder: (context, state) {
          final category = _categoryFromName(state.pathParameters['category']);

          if (category == null) {
            return _errorPage('Invalid game category');
          }

          return _modalPage(
            state,
            GameScreen(
              gameCategory: category,
              paidWithCoin: state.uri.queryParameters['paidWithCoin'] == 'true',
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.subscription,
        pageBuilder: (context, state) => _modalPage(
          state,
          SubscriptionScreen(
            tabType: _tabFromName(state.uri.queryParameters['tab']),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.leaderboard,
        pageBuilder: (context, state) => _modalPage(state, const LeaderboardScreen()),
      ),
      GoRoute(
        path: RouteNames.achievements,
        pageBuilder: (context, state) => _modalPage(state, const AchievementsScreen()),
      ),
      GoRoute(
        path: RouteNames.settings,
        pageBuilder: (context, state) => _modalPage(state, const SettingsScreen()),
      ),
      GoRoute(
        path: RouteNames.feedback,
        pageBuilder: (context, state) => _modalPage(state, const FeedbackScreen()),
      ),
      GoRoute(
        path: RouteNames.about,
        pageBuilder: (context, state) => _modalPage(state, const AboutZifroManiaScreen()),
      ),
      GoRoute(
        path: RouteNames.privacy,
        pageBuilder: (context, state) => _modalPage(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: RouteNames.terms,
        pageBuilder: (context, state) => _modalPage(state, const TermsOfServiceScreen()),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<dynamic>>(
      authNotifierProvider,
      (previous, next) {
        final userChanged = previous?.value != next.value;
        final loadingChanged = previous?.isLoading != next.isLoading;

        if (userChanged || loadingChanged) {
          notifyListeners();
        }
      },
    );
  }
}

GameCategory? _categoryFromName(String? name) {
  for (final category in GameCategory.values) {
    if (category.name == name) {
      return category;
    }
  }

  return null;
}

TabType _tabFromName(String? name) {
  return name == 'coins' ? TabType.coins : TabType.subscription;
}

Page<void> _modalPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: FractionallySizedBox(
          heightFactor: .99,
          widthFactor: 1,
          child: child,
        ),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeOut),
          ),
        ),
        child: child,
      );
    },
  );
}

Page<void> _errorPage(String message) {
  return MaterialPage<void>(
    child: Scaffold(
      body: Center(
        child: Text(message),
      ),
    ),
  );
}
