import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/core/providers/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  String _selectedLanguage = 'English (US)';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final usersNotifier = ref.read(usersProvider.notifier);
    await usersNotifier.fetchCurrentUser();
    
    final user = ref.read(usersProvider).currentUser;
    if (user != null && user.name != null) {
      _displayNameController.text = user.name!;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final newName = _displayNameController.text.trim();
    if (newName.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final usersNotifier = ref.read(usersProvider.notifier);
      await usersNotifier.updateUser(currentUser.id, {'name': newName});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      final authService = ref.read(authActionsProvider);
      await authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userState = ref.watch(usersProvider);
    final userData = userState.currentUser;
    final email = currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.titleMedium(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar and Email Section
              Row(
                children: [
                  // Avatar Circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary1,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        email.isNotEmpty ? email[0].toUpperCase() : 'A',
                        style: AppTextStyles.titleLarge(color: AppColors.text3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Email and Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: AppTextStyles.titleSmall(color: AppColors.text1),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have analyzed 415 plots, you are a winner!',
                          style: AppTextStyles.regularText(color: AppColors.text2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Display Name Field
              Text(
                'Display name',
                style: AppTextStyles.regularText(color: AppColors.text2),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.text3,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _displayNameController,
                        style: AppTextStyles.titleSmall(color: AppColors.text1),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.text2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.check, color: AppColors.primary1),
                        onPressed: _updateDisplayName,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Language Field
              Text(
                'Language',
                style: AppTextStyles.regularText(color: AppColors.text2),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.text3,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke, width: 1),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppColors.text2,
                  ),
                  title: Text(
                    _selectedLanguage,
                    style: AppTextStyles.titleSmall(color: AppColors.text1),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.text2,
                  ),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Sign Out Button
              Center(
                child: TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Sign out',
                    style: AppTextStyles.titleSmall(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: AppTextStyles.titleSmall(color: AppColors.text1),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('English (US)'),
            _languageOption('English (UK)'),
            _languageOption('Spanish'),
            _languageOption('French'),
            _languageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language) {
    return ListTile(
      title: Text(
        language,
        style: AppTextStyles.regularText(color: AppColors.text1),
      ),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: AppColors.primary1)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }
}
