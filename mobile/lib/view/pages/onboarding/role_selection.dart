import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/constants/styles/app_styles.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  static const List<Map<String, String>> roleOptions = [
    {'icon': '🏗️', 'label': 'Real Estate Developer', 'value': 'developer'},
    {'icon': '💼', 'label': 'Investor', 'value': 'investor'},
    {'icon': '🌱', 'label': 'Landowner', 'value': 'landowner'},
    {'icon': '🏘️', 'label': 'Real Estate Agent', 'value': 'agent'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.primary1,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      'Tell us about\nyourself',
                      style: AppTextStyles.labelLarge(color: AppColors.secondary2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'We\'ll personalize your experience\nbased on your role',
                      style: AppTextStyles.labelSubtitle(color: AppColors.secondary2),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Role options
                    ...roleOptions.map((role) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RoleOption(
                        icon: role['icon']!,
                        label: role['label']!,
                        value: role['value']!,
                        selectedRole: selectedRole,
                        onTap: () {
                          ref.read(userRoleProvider.notifier).state = role['value'];
                        },
                      ),
                    )),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Continue button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  
                  onPressed: selectedRole != null
                      ? () {
                          // Navigate to sign up page
                          Navigator.pushNamed(context, '/signup');
                        }
                      : null,
                  style: AppStyles.roundedButtonStyle(
                    backgroundColor: selectedRole != null 
                        ? AppColors.secondary2 
                        : AppColors.secondary2.withValues(alpha: 0.8),
                    foregroundColor:selectedRole != null 
                        ? AppColors.primary3
                        : AppColors.primary1,
                    
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary3,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? selectedRole;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRole == value;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary2 : AppColors.primary3,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.secondary2 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.titleSmall(
                color: isSelected ? AppColors.primary3 : AppColors.secondary2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
