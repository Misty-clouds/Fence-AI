import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/research_messages_model.dart';

class ResearchMessagesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all messages for a conversation
  Future<List<ResearchMessageModel>> getMessagesByConversation(String conversationId) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      
      return (response as List)
          .map((message) => ResearchMessageModel.fromJson(message))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Get message by ID
  Future<ResearchMessageModel?> getMessageById(int id) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return ResearchMessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch message: $e');
    }
  }

  // Get messages by researcher
  Future<List<ResearchMessageModel>> getMessagesByResearcher(String researcherId) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .select()
          .eq('researcher_id', researcherId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((message) => ResearchMessageModel.fromJson(message))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages by researcher: $e');
    }
  }

  // Create new message
  Future<ResearchMessageModel> createMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .insert(messageData)
          .select()
          .single();
      
      return ResearchMessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  // Send a text message
  Future<ResearchMessageModel> sendTextMessage({
    required String conversationId,
    required String researcherId,
    required String content,
  }) async {
    try {
      return await createMessage({
        'conversation_id': conversationId,
        'researcher_id': researcherId,
        'content': content,
        'content_type': 'text',
        'message_type': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send text message: $e');
    }
  }

  // Receive a message (e.g., from AI)
  Future<ResearchMessageModel> receiveMessage({
    required String conversationId,
    required String content,
    ContentType contentType = ContentType.text,
  }) async {
    try {
      return await createMessage({
        'conversation_id': conversationId,
        'content': content,
        'content_type': contentType.toJson(),
        'message_type': 'received',
      });
    } catch (e) {
      throw Exception('Failed to receive message: $e');
    }
  }

  // Send an image message
  Future<ResearchMessageModel> sendImageMessage({
    required String conversationId,
    required String researcherId,
    required String imageUrl,
  }) async {
    try {
      return await createMessage({
        'conversation_id': conversationId,
        'researcher_id': researcherId,
        'content': imageUrl,
        'content_type': 'image',
        'message_type': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  // Send a file message
  Future<ResearchMessageModel> sendFileMessage({
    required String conversationId,
    required String researcherId,
    required String fileUrl,
  }) async {
    try {
      return await createMessage({
        'conversation_id': conversationId,
        'researcher_id': researcherId,
        'content': fileUrl,
        'content_type': 'file',
        'message_type': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send file message: $e');
    }
  }

  // Send an audio file message
  Future<ResearchMessageModel> sendAudioMessage({
    required String conversationId,
    required String researcherId,
    required String audioUrl,
  }) async {
    try {
      return await createMessage({
        'conversation_id': conversationId,
        'researcher_id': researcherId,
        'content': audioUrl,
        'content_type': 'audio_file',
        'message_type': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send audio message: $e');
    }
  }

  // Update message
  Future<ResearchMessageModel> updateMessage(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      
      return ResearchMessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(int id) async {
    try {
      await _supabase.from('research_messages').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Delete all messages in a conversation
  Future<void> deleteMessagesByConversation(String conversationId) async {
    try {
      await _supabase
          .from('research_messages')
          .delete()
          .eq('conversation_id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete messages: $e');
    }
  }

  // Get message count for a conversation
  Future<int> getMessageCount(String conversationId) async {
    try {
      final response = await _supabase
          .from('research_messages')
          .select()
          .eq('conversation_id', conversationId);
      
      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get message count: $e');
    }
  }
}
