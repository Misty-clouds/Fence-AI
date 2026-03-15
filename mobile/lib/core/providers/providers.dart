import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'research_conversations_provider.dart';
import 'research_messages_provider.dart';
import 'users_provider.dart';

// Create shared provider instances
final researchConversationsProvider =
    ChangeNotifierProvider((ref) => ResearchConversationsProvider());

final researchMessagesProvider =
    ChangeNotifierProvider((ref) => ResearchMessagesProvider());

final usersProvider = ChangeNotifierProvider((ref) => UsersProvider());
