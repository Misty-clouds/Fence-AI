import 'package:flutter/foundation.dart';
import '../models/research_messages_model.dart';
import '../services/research_messages_service.dart';

class ResearchMessagesProvider with ChangeNotifier {
  final ResearchMessagesService _messagesService = ResearchMessagesService();

  List<ResearchMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<ResearchMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  // Fetch messages by conversation
  Future<void> fetchMessagesByConversation(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _messagesService.getMessagesByConversation(conversationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages by researcher
  Future<void> fetchMessagesByResearcher(String researcherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _messagesService.getMessagesByResearcher(researcherId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send text message
  Future<ResearchMessageModel?> sendTextMessage({
    required String conversationId,
    required String researcherId,
    required String content,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _messagesService.sendTextMessage(
        conversationId: conversationId,
        researcherId: researcherId,
        content: content,
      );
      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return message;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }

  // Receive message (e.g., from AI)
  Future<ResearchMessageModel?> receiveMessage({
    required String conversationId,
    required String content,
    ContentType contentType = ContentType.text,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _messagesService.receiveMessage(
        conversationId: conversationId,
        content: content,
        contentType: contentType,
      );
      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return message;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }

  // Send image message
  Future<ResearchMessageModel?> sendImageMessage({
    required String conversationId,
    required String researcherId,
    required String imageUrl,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _messagesService.sendImageMessage(
        conversationId: conversationId,
        researcherId: researcherId,
        imageUrl: imageUrl,
      );
      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return message;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }

  // Send file message
  Future<ResearchMessageModel?> sendFileMessage({
    required String conversationId,
    required String researcherId,
    required String fileUrl,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _messagesService.sendFileMessage(
        conversationId: conversationId,
        researcherId: researcherId,
        fileUrl: fileUrl,
      );
      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return message;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }

  // Send audio message
  Future<ResearchMessageModel?> sendAudioMessage({
    required String conversationId,
    required String researcherId,
    required String audioUrl,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _messagesService.sendAudioMessage(
        conversationId: conversationId,
        researcherId: researcherId,
        audioUrl: audioUrl,
      );
      _messages.add(message);
      _isSending = false;
      notifyListeners();
      return message;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }

  // Update message
  Future<ResearchMessageModel?> updateMessage(
    int id,
    Map<String, dynamic> updates,
  ) async {
    _error = null;
    notifyListeners();

    try {
      final updatedMessage = await _messagesService.updateMessage(id, updates);
      final index = _messages.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
      notifyListeners();
      return updatedMessage;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Delete message
  Future<bool> deleteMessage(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _messagesService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear messages for current conversation
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  // Get message count
  Future<int> getMessageCount(String conversationId) async {
    try {
      return await _messagesService.getMessageCount(conversationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
