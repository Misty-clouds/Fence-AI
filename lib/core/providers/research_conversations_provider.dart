import 'package:flutter/foundation.dart';
import '../models/research_conversation_model.dart';
import '../services/research_conversations_service.dart';

class ResearchConversationsProvider with ChangeNotifier {
  final ResearchConversationsService _conversationsService = ResearchConversationsService();

  List<ResearchConversationModel> _conversations = [];
  ResearchConversationModel? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<ResearchConversationModel> get conversations => _conversations;
  ResearchConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all conversations
  Future<void> fetchAllConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationsService.getAllConversations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch conversations by researcher
  Future<void> fetchConversationsByResearcher(String researcherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationsService.getConversationsByResearcher(researcherId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch conversation by ID
  Future<ResearchConversationModel?> fetchConversationById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation = await _conversationsService.getConversationById(id);
      _isLoading = false;
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Set current conversation
  void setCurrentConversation(ResearchConversationModel? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  // Create conversation
  Future<ResearchConversationModel?> createConversation(
    ResearchConversationModel conversation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newConversation = await _conversationsService.createConversation(conversation);
      _conversations.insert(0, newConversation);
      _isLoading = false;
      notifyListeners();
      return newConversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update conversation
  Future<ResearchConversationModel?> updateConversation(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedConversation = await _conversationsService.updateConversation(id, updates);
      final index = _conversations.indexWhere((conv) => conv.id == id);
      if (index != -1) {
        _conversations[index] = updatedConversation;
      }
      if (_currentConversation?.id == id) {
        _currentConversation = updatedConversation;
      }
      _isLoading = false;
      notifyListeners();
      return updatedConversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update conversation title
  Future<bool> updateTitle(String id, String title) async {
    try {
      final updated = await _conversationsService.updateTitle(id, title);
      final index = _conversations.indexWhere((conv) => conv.id == id);
      if (index != -1) {
        _conversations[index] = updated;
      }
      if (_currentConversation?.id == id) {
        _currentConversation = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update location data
  Future<bool> updateLocationData(String id, Map<String, dynamic> locationData) async {
    try {
      final updated = await _conversationsService.updateLocationData(id, locationData);
      final index = _conversations.indexWhere((conv) => conv.id == id);
      if (index != -1) {
        _conversations[index] = updated;
      }
      if (_currentConversation?.id == id) {
        _currentConversation = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete conversation
  Future<bool> deleteConversation(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _conversationsService.deleteConversation(id);
      _conversations.removeWhere((conv) => conv.id == id);
      if (_currentConversation?.id == id) {
        _currentConversation = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current conversation
  void clearCurrentConversation() {
    _currentConversation = null;
    notifyListeners();
  }
}
