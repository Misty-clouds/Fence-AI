import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/view/pages/main/dashboard.dart';
import 'package:fence_ai/view/pages/onboarding/loading_splash.dart';
import 'package:fence_ai/view/pages/onboarding/splashcreen.dart';
import 'package:fence_ai/view/widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data) {
        final user = data.session?.user;
        if (user == null) {
          return const Splashscreen();
        }
        return const Dashboard();
      
      },
      loading: () => const LoadingSplash(),
      error: (err, stack) {
        debugPrint('Auth state error: $err');
        debugPrint('Stack trace: $stack');
        return ErrorPage(
          title: 'Connection Error',
          message:
              'Failed to connect to authentication service: ${err.toString()}',
          onRetry: () {
            ref.invalidate(authStateProvider);
          },
        );
      },
    );
  }
}
