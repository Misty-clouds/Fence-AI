import 'package:fence_ai/auth/providers/auth_provider.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/core/providers/providers.dart';
import 'package:fence_ai/core/models/research_conversation_model.dart';
import 'package:fence_ai/view/pages/main/profile.dart';
import 'package:fence_ai/view/pages/main/research_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideBar extends ConsumerStatefulWidget {
  const SideBar({super.key});

  @override
  ConsumerState<SideBar> createState() => _SideBarState();
}

class _SideBarState extends ConsumerState<SideBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final conversationsNotifier = ref.read(researchConversationsProvider.notifier);
      await conversationsNotifier.fetchConversationsByResearcher(currentUser.id);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getUserInitial() {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : 'A';
  }

  List<ResearchConversationModel> _getConversationsForTimeRange(
    List<ResearchConversationModel> conversations,
    DateTime rangeStart,
    DateTime? rangeEnd,
  ) {
    return conversations.where((conv) {
      if (rangeEnd != null) {
        return conv.createdAt.isAfter(rangeStart) && conv.createdAt.isBefore(rangeEnd);
      } else {
        return conv.createdAt.isAfter(rangeStart);
      }
    }).toList();
  }

  void _navigateToConversation(String conversationId, String? title) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResearchChat(
          conversationId: conversationId,
          conversationTitle: title,
        ),
      ),
    );
  }

  Future<void> _createNewConversation() async {
    Navigator.pop(context); // Close drawer first
    
    // Navigate to home page
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _handleLogout() async {
    try {
      final authService = ref.read(authActionsProvider);
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showItemMenu(BuildContext context, String conversationId, String currentTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.text3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.text2),
              title: Text('Rename', style: AppTextStyles.regularText()),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(conversationId, currentTitle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete', style: AppTextStyles.regularText(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(conversationId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(String conversationId, String currentTitle) {
    final titleController = TextEditingController(text: currentTitle);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Conversation', style: AppTextStyles.titleSmall()),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.regularText(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                final conversationsNotifier = ref.read(researchConversationsProvider.notifier);
                await conversationsNotifier.updateTitle(conversationId, newTitle);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conversation renamed successfully')),
                  );
                }
              }
            },
            child: Text('Rename', style: AppTextStyles.regularText(color: AppColors.primary1)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConversation(String conversationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversation', style: AppTextStyles.titleSmall()),
        content: Text('Are you sure you want to delete this conversation? This action cannot be undone.', 
          style: AppTextStyles.regularText()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.regularText(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: AppTextStyles.regularText(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final conversationsNotifier = ref.read(researchConversationsProvider.notifier);
      final success = await conversationsNotifier.deleteConversation(conversationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Conversation deleted' : 'Failed to delete conversation'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: AppColors.text3,
      child: SafeArea(
        child: Column(
          children: [
            // Header with avatar and menu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context) => ProfilePage())),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary1,
                      child: Text(
                        _getUserInitial(),
                        style: AppTextStyles.titleSmall(color: AppColors.text3),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/icons/view_sidebar.png',height: 40,),
              
                )
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.regularText(color: AppColors.text1),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.regularText(color: AppColors.text2),
                  prefixIcon: const Icon(Icons.search, color: AppColors.text2),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

              // New survey button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createNewConversation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary1,
                    foregroundColor: AppColors.text3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'New survey',
                        style: AppTextStyles.titleSmall(color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Survey list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer(
                      builder: (context, ref, _) {
                        final conversationsState = ref.watch(researchConversationsProvider);
                        final conversations = conversationsState.conversations;
                        
                        if (conversations.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'No conversations yet.\nTap "New survey" to start!',
                                style: AppTextStyles.regularText(color: AppColors.text2),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final now = DateTime.now();
                        final todayStart = DateTime(now.year, now.month, now.day);
                        final lastWeekStart = todayStart.subtract(const Duration(days: 7));

                        final todayConversations = _getConversationsForTimeRange(
                          conversations,
                          todayStart,
                          null,
                        );
                        
                        final lastWeekConversations = _getConversationsForTimeRange(
                          conversations,
                          lastWeekStart,
                          todayStart,
                        );

                        final olderConversations = conversations
                            .where((conv) => conv.createdAt.isBefore(lastWeekStart))
                            .toList();

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // Today section
                            if (todayConversations.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Today',
                                  style: AppTextStyles.regularText(color: AppColors.text2),
                                ),
                              ),
                              ...todayConversations.map((conv) => _buildSurveyItem(conv)),
                              const SizedBox(height: 24),
                            ],

                            // Last week section
                            if (lastWeekConversations.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Last week',
                                  style: AppTextStyles.regularText(color: AppColors.text2),
                                ),
                              ),
                              ...lastWeekConversations.map((conv) => _buildSurveyItem(conv)),
                              const SizedBox(height: 24),
                            ],

                            // Older section
                            if (olderConversations.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Older',
                                  style: AppTextStyles.regularText(color: AppColors.text2),
                                ),
                              ),
                              ...olderConversations.map((conv) => _buildSurveyItem(conv)),
                            ],
                          ],
                        );
                      },
                    ),
            ),

            // Bottom section with Settings and Logout
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.text2),
                    title: Text(
                      'Settings',
                      style: AppTextStyles.regularText(color: AppColors.text1),
                    ),
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      'Logout',
                      style: AppTextStyles.regularText(color: AppColors.error),
                    ),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyItem(ResearchConversationModel conversation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _navigateToConversation(conversation.id, conversation.title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.title ?? 'Untitled conversation',
                  style: AppTextStyles.regularText(color: AppColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.text2, size: 20),
                onPressed: () => _showItemMenu(
                  context,
                  conversation.id,
                  conversation.title ?? 'Untitled conversation',
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
