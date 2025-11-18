import "package:flutter/material.dart";
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/widgets/side_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fence_ai/core/providers/providers.dart';
import 'package:fence_ai/core/models/research_messages_model.dart';
import 'package:fence_ai/auth/providers/auth_provider.dart';

class ResearchChat extends ConsumerStatefulWidget {
  final String? conversationId;
  final String? conversationTitle;
  
  const ResearchChat({
    super.key,
    this.conversationId,
    this.conversationTitle,
  });

  @override
  ConsumerState<ResearchChat> createState() => _ResearchChatState();
}

class _ResearchChatState extends ConsumerState<ResearchChat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedQuestions = [
    'What is the best place to build a school in lagos?',
    'Plot analysis for commercial areas',
  ];

  @override
  void initState() {
    super.initState();
    // Load messages and conversation if conversationId exists
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messagesNotifier = ref.read(researchMessagesProvider.notifier);
        messagesNotifier.fetchMessagesByConversation(widget.conversationId!);
        
        // Fetch conversation to get location data
        final conversationsNotifier = ref.read(researchConversationsProvider.notifier);
        conversationsNotifier.fetchConversationById(widget.conversationId!);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (widget.conversationId == null) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    _messageController.clear();

    // Send message
    final messagesNotifier = ref.read(researchMessagesProvider.notifier);
    await messagesNotifier.sendTextMessage(
      conversationId: widget.conversationId!,
      researcherId: currentUser.id,
      content: text,
    );

    // Scroll to bottom
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () async {
      await messagesNotifier.receiveMessage(
        conversationId: widget.conversationId!,
        content: "combines intuitive map interactions with advanced AI insights to help developers, investors, and landowners make data-driven decisions on-the-go.\n\nKey Objectives\n• Deliver a mobile-first, touch-optimized experience for land discovery and analysis\n• Provide instant AI-powered recommendations for optimal land utilization\n• Enable seamless plot selection and evaluation through intuitive gestures\n• Launch MVP within 3-4 weeks with core functionality",
        contentType: ContentType.text,
      );

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.text1, size: 28),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: widget.conversationTitle != null
            ? Text(
                widget.conversationTitle!,
                style: AppTextStyles.titleSmall(color: AppColors.text1),
              )
            : null,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final conversationsState = ref.watch(researchConversationsProvider);
              
              if (conversationsState.conversations.isEmpty || widget.conversationId == null) {
                return IconButton(
                  icon: const Icon(Icons.map_outlined, color: AppColors.text1, size: 28),
                  onPressed: null,
                );
              }
              
              final conversation = conversationsState.conversations.firstWhere(
                (c) => c.id == widget.conversationId,
                orElse: () => conversationsState.conversations.first,
              );
              final hasLocationData = conversation.locationData != null;
              
              return IconButton(
                icon: Icon(
                  hasLocationData ? Icons.map : Icons.map_outlined,
                  color: hasLocationData ? AppColors.primary1 : AppColors.text1,
                  size: 28,
                ),
                onPressed: hasLocationData
                    ? () => _showLocationMapBottomSheet(conversation.locationData!)
                    : null,
              );
            },
          ),
        ],
      ),
      drawer: const SideBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final messagesState = ref.watch(researchMessagesProvider);
                final messages = messagesState.messages;

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isFirstAIMessage = index == 0 && 
                        messages[index].messageType == MessageContentType.received;
                    return _buildMessageBubble(messages[index], isFirstAIMessage);
                  },
                );
              },
            ),
          ),

          // Suggested questions (show only when no messages)
          Consumer(
            builder: (context, ref, _) {
              final messagesState = ref.watch(researchMessagesProvider);
              final messages = messagesState.messages;
              
              if (messages.isNotEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedQuestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => _sendMessage(_suggestedQuestions[index]),
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              _suggestedQuestions[index],
                              style: AppTextStyles.regularText(color: AppColors.text1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attach button
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                    onPressed: () {
                      // Handle attachment
                    },
                  ),
                  
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask Fense anything..',
                        hintStyle: AppTextStyles.regularText(
                          color: Colors.grey.shade500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppColors.primary1, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary1,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What are you\nexploring today?',
              style: AppTextStyles.titleLarge(color: AppColors.text1).copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'I can help you discover the perfect location for your project',
              style: AppTextStyles.regularText(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ResearchMessageModel message, bool isFirstAIMessage) {
    final isUser = message.messageType == MessageContentType.sent;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary1 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isUser ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isUser
                    ? Text(
                        message.content ?? '',
                        style: AppTextStyles.regularText(
                          color: Colors.white,
                        ).copyWith(height: 1.5),
                      )
                    : MarkdownBody(
                        data: message.content ?? '',
                        styleSheet: MarkdownStyleSheet(
                          h1: AppTextStyles.titleMedium().copyWith(
                            fontSize: 20,
                            color: AppColors.primary1,
                          ),
                          h2: AppTextStyles.titleMedium().copyWith(
                            fontSize: 18,
                            color: AppColors.primary1,
                          ),
                          h3: AppTextStyles.regularTextBold().copyWith(
                            fontSize: 16,
                            color: AppColors.text1,
                          ),
                          p: AppTextStyles.regularText().copyWith(
                            height: 1.6,
                            color: AppColors.text2,
                          ),
                          strong: AppTextStyles.regularTextBold().copyWith(
                            color: AppColors.text1,
                          ),
                          em: AppTextStyles.regularText().copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.text2,
                          ),
                          listBullet: AppTextStyles.regularText().copyWith(
                            color: AppColors.primary1,
                          ),
                          blockSpacing: 8,
                        ),
                      ),
                
                // Show map preview for first AI message
                if (isFirstAIMessage && !isUser) ...[
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final conversationsState = ref.watch(researchConversationsProvider);
                      
                      if (conversationsState.conversations.isEmpty || widget.conversationId == null) {
                        return const SizedBox.shrink();
                      }
                      
                      final conversation = conversationsState.conversations.firstWhere(
                        (c) => c.id == widget.conversationId,
                        orElse: () => conversationsState.conversations.first,
                      );
                      
                      if (conversation.locationData == null) {
                        return const SizedBox.shrink();
                      }
                      
                      return _buildMapPreview(conversation.locationData!);
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // Message actions (copy, like, dislike, refresh) for AI messages only
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMessageAction(Icons.content_copy, () {}),
                  const SizedBox(width: 16),
                  _buildMessageAction(Icons.thumb_up_outlined, () {}),
                  const SizedBox(width: 16),
                  _buildMessageAction(Icons.thumb_down_outlined, () {}),
                  const SizedBox(width: 16),
                  _buildMessageAction(Icons.refresh, () {}),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMapPreview(Map<String, dynamic> locationData) {
    final center = locationData['center'] as Map<String, dynamic>?;
    final area = locationData['area'] as Map<String, dynamic>?;
    
    if (center == null) return const SizedBox.shrink();
    
    final acres = area?['acres'] as double? ?? 0.0;
    
    return InkWell(
      onTap: () => _showLocationMapBottomSheet(locationData),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary1.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.map,
                color: AppColors.primary1,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Researched Area',
                    style: AppTextStyles.regularTextBold().copyWith(
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${acres.toStringAsFixed(2)} acres',
                    style: AppTextStyles.subTitle(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view on map',
                    style: AppTextStyles.subTitle().copyWith(
                      color: AppColors.primary1,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary1,
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationMapBottomSheet(Map<String, dynamic> locationData) {
    final center = locationData['center'] as Map<String, dynamic>?;
    final polygonPoints = locationData['polygon_points'] as List?;
    final area = locationData['area'] as Map<String, dynamic>?;
    
    if (center == null) return;
    
    final latitude = center['latitude'] as double;
    final longitude = center['longitude'] as double;
    final acres = area?['acres'] as double? ?? 0.0;
    final squareMeters = area?['square_meters'] as double? ?? 0.0;
    final hectares = area?['hectares'] as double? ?? 0.0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary1,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Researched Location',
                            style: AppTextStyles.titleMedium().copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${acres.toStringAsFixed(2)} acres',
                            style: AppTextStyles.subTitle(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Map view
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 16.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('center'),
                      position: LatLng(latitude, longitude),
                    ),
                  },
                  polygons: polygonPoints != null
                      ? {
                          Polygon(
                            polygonId: const PolygonId('researched_area'),
                            points: polygonPoints
                                .map<LatLng>((point) => LatLng(
                                      point['latitude'] as double,
                                      point['longitude'] as double,
                                    ))
                                .toList(),
                            fillColor: AppColors.primary1.withOpacity(0.3),
                            strokeColor: AppColors.primary1,
                            strokeWidth: 3,
                          ),
                        }
                      : {},
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
              
              // Area info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAreaInfo('Acres', acres.toStringAsFixed(2)),
                        _buildAreaInfo('Hectares', hectares.toStringAsFixed(2)),
                        _buildAreaInfo('Sq Meters', squareMeters.toStringAsFixed(0)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Coordinates: ${latitude.toStringAsFixed(6)}°, ${longitude.toStringAsFixed(6)}°',
                      style: AppTextStyles.subTitle(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.regularTextBold().copyWith(
            fontSize: 18,
            color: AppColors.primary1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.subTitle(),
        ),
      ],
    );
  }
}
