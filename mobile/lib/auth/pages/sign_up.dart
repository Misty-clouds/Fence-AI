import 'package:fence_ai/auth/pages/email_signup.dart';
import 'package:fence_ai/auth/pages/sign_in.dart';
import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authActionsProvider);
      await authService.signInWithGoogle();
      // Navigation will be handled by deep link callback
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authActionsProvider);
      await authService.signInWithApple();
      // Navigation will be handled by deep link callback
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 23,
                  width: 82,
                ),
              ),
              Spacer(flex: 2,),
              // Title
              Text(
                'Let\'s Get\nYou In',
                style: AppTextStyles.labelLarge(color: AppColors.secondary2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Sign in or create an account\nto start exploring',
                style: AppTextStyles.labelSubtitle(color: AppColors.secondary2),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Continue with Google button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _handleGoogleSignIn(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary2,
                    foregroundColor: AppColors.primary3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue with Google',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: AppColors.primary3,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue with Apple button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _handleAppleSignIn(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary2,
                    foregroundColor: AppColors.primary3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue with Apple',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.apple,
                        color: AppColors.primary3,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue with email button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailSignUpPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary2,
                    foregroundColor: AppColors.primary3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue email',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.mail_outline,
                        color: AppColors.primary3,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // SignIn button
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => SignInPage(),));
                },
                child: Text(
                  'Sign In',
                  style: AppTextStyles.titleSmall(color: AppColors.secondary2),
                ),
              ),

              const Spacer(flex: 2),

              // Terms and Privacy
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.regularText(
                      color: AppColors.secondary2.withOpacity(0.7),
                    ),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
