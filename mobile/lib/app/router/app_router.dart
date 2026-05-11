import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fence_ai/app/router/routes.dart';
import 'package:fence_ai/core/widgets/error_page.dart';
import 'package:fence_ai/features/auth/presentation/pages/sign_in.dart';
import 'package:fence_ai/features/auth/presentation/pages/sign_up.dart';
import 'package:fence_ai/features/auth/presentation/pages/email_signup.dart';
import 'package:fence_ai/features/auth/presentation/pages/forgot_password.dart';
import 'package:fence_ai/features/auth/presentation/pages/reset_password.dart';
import 'package:fence_ai/features/home/presentation/pages/home.dart';
import 'package:fence_ai/features/map/presentation/pages/map.dart';
import 'package:fence_ai/features/research/presentation/pages/research_chat.dart';
import 'package:fence_ai/features/profile/presentation/pages/profile.dart';
import 'package:fence_ai/features/payment/presentation/pages/upgrade_page.dart';
import 'package:fence_ai/features/compare/presentation/pages/compare_plot.dart';
import 'package:fence_ai/features/onboarding/presentation/pages/splashcreen.dart';
import 'package:fence_ai/features/onboarding/presentation/pages/loading_splash.dart';
import 'package:fence_ai/features/onboarding/presentation/pages/onboarding1.dart';
import 'package:fence_ai/features/onboarding/presentation/pages/onboarding2.dart';
import 'package:fence_ai/features/onboarding/presentation/pages/role_selection.dart';

// Bridges a Supabase auth stream into a GoRouter refresh notifier.
class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Routes where an authenticated user should NOT be redirected to /home.
const _authOnlyRoutes = {
  Routes.forgotPassword,
  Routes.resetPassword,
  Routes.onboarding1,
  Routes.onboarding2,
  Routes.roleSelection,
};

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.loading,
    refreshListenable: _AuthRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;

      // Unauthenticated user trying to reach a protected route → splash
      final isPublicRoute = _authOnlyRoutes.contains(loc) ||
          loc == Routes.loading ||
          loc == Routes.splash ||
          loc == Routes.signIn ||
          loc == Routes.signUp ||
          loc == Routes.emailSignup;

      if (!isLoggedIn && !isPublicRoute) return Routes.splash;

      // Authenticated user sitting on a login/splash route → home
      if (isLoggedIn &&
          (loc == Routes.loading ||
              loc == Routes.splash ||
              loc == Routes.signIn ||
              loc == Routes.signUp ||
              loc == Routes.emailSignup)) {
        return Routes.home;
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorPage(
      title: 'Page Not Found',
      message: state.error?.message ?? 'The requested route does not exist.',
      onRetry: () => context.go(Routes.home),
    ),
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (_, __) => const LoadingSplash(),
      ),
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const Splashscreen(),
      ),
      GoRoute(
        path: Routes.onboarding1,
        builder: (_, __) => const Onboarding1(),
      ),
      GoRoute(
        path: Routes.onboarding2,
        builder: (_, __) => const Onboarding2(),
      ),
      GoRoute(
        path: Routes.roleSelection,
        builder: (_, __) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, __) => const SignInPage(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: Routes.emailSignup,
        builder: (_, __) => const EmailSignUpPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, state) => ResetPasswordPage(
          email: state.uri.queryParameters['email'],
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: Routes.map,
        builder: (_, state) => MapPage(
          conversationId: state.uri.queryParameters['conversationId'],
        ),
      ),
      GoRoute(
        path: Routes.research,
        builder: (_, state) => ResearchChat(
          conversationId: state.uri.queryParameters['conversationId'],
          conversationTitle: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: Routes.upgrade,
        builder: (_, __) => const UpgradePage(),
      ),
      GoRoute(
        path: Routes.compare,
        builder: (_, __) => const ComparePlot(),
      ),
    ],
  );
}
