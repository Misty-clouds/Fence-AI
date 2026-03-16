import 'package:flutter/material.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/pages/payment/upgrade_page.dart';

class UpgradePromptSheet extends StatelessWidget {
  final bool isDismissible;
  final int? researchRemaining;
  final int? chatRemaining;
  final VoidCallback? onUpgrade;

  const UpgradePromptSheet({
    super.key,
    this.isDismissible = true,
    this.researchRemaining,
    this.chatRemaining,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDismissible)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDismissible ? Icons.rocket_launch : Icons.lock,
                      size: 48,
                      color: AppColors.primary1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isDismissible
                        ? 'Unlock Premium Features'
                        : 'Free Limit Reached',
                    style: AppTextStyles.titleLarge(color: AppColors.text1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isDismissible
                        ? 'Upgrade to access unlimited land research, AI chat, and advanced analytics.'
                        : 'You\'ve used all your free prompts. Upgrade now to continue using Fence AI.',
                    style: AppTextStyles.regularText(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (!isDismissible &&
                      (researchRemaining != null || chatRemaining != null))
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Free Tier Usage',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.text1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildUsageStat(
                                icon: Icons.map_outlined,
                                label: 'Research',
                                value: '3/3',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                              _buildUsageStat(
                                icon: Icons.chat_bubble_outline,
                                label: 'Chat',
                                value: '1/1',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (!isDismissible) const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary1.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Premium Features',
                          style: AppTextStyles.titleSmall(
                            color: AppColors.text1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem('Unlimited land research prompts'),
                        _buildFeatureItem('Unlimited AI chat conversations'),
                        _buildFeatureItem('Advanced analytics & insights'),
                        _buildFeatureItem('Priority support'),
                        _buildFeatureItem('Export reports & data'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          onUpgrade ??
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpgradePage(),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary1,
                        foregroundColor: AppColors.text3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Upgrade Now',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isDismissible) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Maybe Later',
                        style: AppTextStyles.regularText(
                          color: AppColors.text2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.primary1),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.regularText(color: AppColors.text1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.error),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.regularText(
            color: AppColors.text2,
          ).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall(
            color: AppColors.text1,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    bool isDismissible = true,
    int? researchRemaining,
    int? chatRemaining,
    VoidCallback? onUpgrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpgradePromptSheet(
        isDismissible: isDismissible,
        researchRemaining: researchRemaining,
        chatRemaining: chatRemaining,
        onUpgrade: onUpgrade,
      ),
    );
  }
}
