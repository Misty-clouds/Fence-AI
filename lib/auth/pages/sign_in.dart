import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authActionsProvider);
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text3,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Welcome back',
                  style: AppTextStyles.titleLarge(color: AppColors.text1),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Enter your email and password to access your account',
                  style: AppTextStyles.regularText(color: AppColors.text2),
                ),

                const SizedBox(height: 40),

                // Email label
                Text(
                  'Email address',
                  style: AppTextStyles.titleSmall(color: AppColors.text1),
                ),
                const SizedBox(height: 8),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.regularText(color: AppColors.text1),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.text3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.stroke, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.stroke, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary1,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password label
                Text(
                  'Password',
                  style: AppTextStyles.titleSmall(color: AppColors.text1),
                ),
                const SizedBox(height: 8),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.regularText(color: AppColors.text1),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.text3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.stroke, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.stroke, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary1,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.text2,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot password link
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Navigate to forgot password
                    },
                    child: Text(
                      'Forgot Password',
                      style: AppTextStyles.regularText(
                        color: AppColors.primary1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary1,
                      foregroundColor: AppColors.text3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.text3,
                            ),
                          )
                        : Text(
                            'Login',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.text3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Or login with
                Center(
                  child: Text(
                    'Or login with',
                    style: AppTextStyles.regularText(color: AppColors.text2),
                  ),
                ),
                const SizedBox(height: 24),

                // Google button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement Google sign in
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.text3,
                      side: BorderSide(color: AppColors.stroke, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, size: 24);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Google',
                          style: AppTextStyles.titleSmall(
                            color: AppColors.text1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/role-selection');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: AppTextStyles.regularText(
                            color: AppColors.text2,
                          ),
                        ),
                        Text(
                          'Sign Up',
                          style: AppTextStyles.regularTextBold(
                            color: AppColors.primary1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
