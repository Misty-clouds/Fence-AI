import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/pages/main/map.dart';
import 'package:fence_ai/view/pages/main/research_chat.dart';
import 'package:fence_ai/view/widgets/side_bar.dart';
import 'package:fence_ai/view/widgets/upgrade_prompt_sheet.dart';
import 'package:fence_ai/core/services/usage_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fence_ai/core/providers/providers.dart';
import 'package:fence_ai/core/models/research_conversation_model.dart';
import 'package:fence_ai/core/models/users_model.dart';
import 'package:fence_ai/auth/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedOption = 0; // Default to first option (Discover on Map)
  final UsageTrackingService _usageTracking = UsageTrackingService();

  @override
  void initState() {
    super.initState();
    _showInitialUpgradePromptIfNeeded();
  }

  Future<void> _showInitialUpgradePromptIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final hasSeenPrompt = await _usageTracking.hasSeenInitialUpgradePrompt();

    if (!hasSeenPrompt) {
      await UpgradePromptSheet.show(context, isDismissible: true);
      await _usageTracking.markInitialUpgradePromptSeen();
    }
  }

  // Options data
  final List<Map<String, dynamic>> _options = [
    {
      'icon': Icons.map_outlined,
      'title': 'Discover on Map',
      'description':
          'Browse the interactive map, pick a site, and let our AI suggest the most profitable development options tailored to that location',
    },
    {
      'icon': Icons.balance_outlined,
      'title': 'Compare Plots',
      'description':
          'Pick multiple properties and review them side by side, see how they stack up in zoning rules, profit potential, and project suitability',
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Just Chat with Fense',
      'description':
          'Not sure where to start?, Have a conversation with Fenseto start your Land acquisition  journey',
    },
  ];

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
    });
  }

  void _handleContinue() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option to continue'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _showSurveyTitleDialog();
  }

  void _showSurveyTitleDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Name Your Survey',
          style: AppTextStyles.titleSmall(color: AppColors.text1),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Give your survey a title to help you identify it later',
              style: AppTextStyles.regularText(color: AppColors.text2),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., School Site in Lagos',
                hintStyle: AppTextStyles.regularText(color: AppColors.text2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary1, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _createConversationAndNavigate(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.regularText(color: AppColors.text2),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a title'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _createConversationAndNavigate(title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary1,
              foregroundColor: AppColors.text3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.regularText(color: AppColors.text3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createConversationAndNavigate(String title) async {
    print('🔍 DEBUG: Starting conversation creation');
    print('🔍 DEBUG: Title: $title');

    final currentUser = ref.read(currentUserProvider);
    print('🔍 DEBUG: Current user: ${currentUser?.id}');
    print('🔍 DEBUG: User email: ${currentUser?.email}');
    print('🔍 DEBUG: User object: $currentUser');

    if (currentUser == null) {
      print('❌ DEBUG: No current user found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to create a survey'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // First, ensure user exists in users table
      print('🔍 DEBUG: Checking if user exists in users table...');
      final usersNotifier = ref.read(usersProvider.notifier);
      await usersNotifier.fetchCurrentUser();

      final userState = ref.read(usersProvider);
      if (userState.currentUser == null) {
        print('🔍 DEBUG: User not found in users table, creating...');
        // Create user in users table
        final newUser = UserModel(
          id: currentUser.id,
          createdAt: DateTime.now(),
          email: currentUser.email ?? '',
          name: currentUser.email?.split('@')[0] ?? 'User',
          role: 'user',
        );
        await usersNotifier.createUser(newUser);
        print('✅ DEBUG: User created successfully');
      } else {
        print('✅ DEBUG: User already exists in users table');
      }

      print('🔍 DEBUG: Getting conversations provider');
      final conversationsNotifier = ref.read(
        researchConversationsProvider.notifier,
      );

      final newConversation = ResearchConversationModel(
        id: '', // Will be generated by Supabase
        createdAt: DateTime.now(),
        title: title,
        researcherId: currentUser.id,
      );

      print('🔍 DEBUG: New conversation object created');
      print('🔍 DEBUG: Conversation details:');
      print('   - Title: ${newConversation.title}');
      print('   - Researcher ID: ${newConversation.researcherId}');
      print('   - Created At: ${newConversation.createdAt}');

      print('🔍 DEBUG: Calling createConversation...');
      final created = await conversationsNotifier.createConversation(
        newConversation,
      );

      print('🔍 DEBUG: Create conversation result: ${created?.id}');
      print('🔍 DEBUG: Created conversation title: ${created?.title}');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (created != null && mounted) {
        print('✅ DEBUG: Successfully created conversation, navigating...');
        // Navigate to appropriate page based on selected option
        _handleOptionActionWithConversation(
          _selectedOption!,
          created.id,
          created.title,
        );
      } else if (mounted) {
        print('❌ DEBUG: Failed to create conversation - returned null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create survey'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception caught during conversation creation');
      print('❌ DEBUG: Error: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleOptionActionWithConversation(
    int index,
    String conversationId,
    String? title,
  ) {
    // Navigate based on selected option
    switch (index) {
      case 0:
        // Navigate to map discovery page with conversation ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(conversationId: conversationId),
          ),
        );
        break;
      case 1:
        // Show coming soon for compare plots
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
        break;
      case 2:
        // Navigate to chat with Fense
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResearchChat(
              conversationId: conversationId,
              conversationTitle: title,
            ),
          ),
        );
        break;
    }
  }

  void _handleOptionAction(int index) {
    // Navigate based on selected option
    switch (index) {
      case 0:
        // Navigate to map discovery page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapPage()),
        );
        break;
      case 1:
        // Show coming soon for compare plots
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
        break;
      case 2:
        // Navigate to chat with Fense
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResearchChat()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      drawer: const Drawer(width: 320, child: SideBar()),
      body: SafeArea(
        child: Column(
          children: [
            // Header with hamburger and map icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    color: AppColors.text1,
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.map_outlined, size: 28),
                    color: AppColors.text1,
                    onPressed: () {
                      // TODO: Quick access to map
                    },
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'What would you like to do?',
                      style: AppTextStyles.titleLarge(color: AppColors.text1),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Choose how you want to explore land opportunities.',
                      style: AppTextStyles.subTitle(color: AppColors.text2),
                    ),
                    const SizedBox(height: 32),

                    // Options mapped from list
                    ..._options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildOptionCard(
                          index: index,
                          icon: option['icon'] as IconData,
                          title: option['title'] as String,
                          description: option['description'] as String,
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 8),

                    // Footer text
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'You can always switch between these options later',
                        style: AppTextStyles.regularText(
                          color: AppColors.text2,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleContinue,
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
                      Text(
                        'Continue',
                        style: AppTextStyles.titleSmall(color: AppColors.text3),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedOption == index;

    return InkWell(
      onTap: () => _selectOption(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary2 : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary1 : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary1.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon at the top left
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: AppColors.primary1),
            ),
            const SizedBox(height: 16),

            // Title and description
            Text(
              title,
              style: AppTextStyles.titleSmall(
                color: AppColors.text1,
              ).copyWith(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.regularText(
                color: AppColors.text2,
              ).copyWith(fontSize: 14, height: 1.5),
            ),

            // Arrow button at bottom right
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => _handleOptionAction(index),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: AppColors.text1,
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
