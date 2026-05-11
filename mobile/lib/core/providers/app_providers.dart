import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fence_ai/features/research/providers/research_conversations_provider.dart';
import 'package:fence_ai/features/research/providers/research_messages_provider.dart';
import 'package:fence_ai/features/users/providers/users_provider.dart';

final researchConversationsProvider =
    ChangeNotifierProvider((ref) => ResearchConversationsProvider());

final researchMessagesProvider =
    ChangeNotifierProvider((ref) => ResearchMessagesProvider());

final usersProvider = ChangeNotifierProvider((ref) => UsersProvider());
