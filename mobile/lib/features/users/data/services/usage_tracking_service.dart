import 'package:shared_preferences/shared_preferences.dart';

class UsageTrackingService {
  static const String _researchCountKey = 'research_prompt_count';
  static const String _chatCountKey = 'chat_message_count';
  static const String _hasSeenInitialPromptKey = 'has_seen_initial_upgrade_prompt';
  
  static const int maxResearchPrompts = 3;
  static const int maxChatMessages = 1;

  Future<int> getResearchPromptCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_researchCountKey) ?? 0;
  }

  Future<int> getChatMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chatCountKey) ?? 0;
  }

  Future<void> incrementResearchPromptCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_researchCountKey) ?? 0;
    await prefs.setInt(_researchCountKey, current + 1);
  }

  Future<void> incrementChatMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_chatCountKey) ?? 0;
    await prefs.setInt(_chatCountKey, current + 1);
  }

  Future<bool> hasSeenInitialUpgradePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenInitialPromptKey) ?? false;
  }

  Future<void> markInitialUpgradePromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenInitialPromptKey, true);
  }

  Future<bool> canSendResearchPrompt() async {
    final count = await getResearchPromptCount();
    return count < maxResearchPrompts;
  }

  Future<bool> canSendChatMessage() async {
    final count = await getChatMessageCount();
    return count < maxChatMessages;
  }

  Future<bool> hasReachedAnyLimit() async {
    final researchCount = await getResearchPromptCount();
    final chatCount = await getChatMessageCount();
    return researchCount >= maxResearchPrompts || chatCount >= maxChatMessages;
  }

  Future<Map<String, dynamic>> getUsageStats() async {
    final researchCount = await getResearchPromptCount();
    final chatCount = await getChatMessageCount();
    
    return {
      'researchCount': researchCount,
      'chatCount': chatCount,
      'researchRemaining': maxResearchPrompts - researchCount,
      'chatRemaining': maxChatMessages - chatCount,
      'hasReachedLimit': researchCount >= maxResearchPrompts || chatCount >= maxChatMessages,
    };
  }

  Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_researchCountKey, 0);
    await prefs.setInt(_chatCountKey, 0);
  }
}
