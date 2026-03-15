import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/research_conversation_model.dart';

class ResearchConversationsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all conversations
  Future<List<ResearchConversationModel>> getAllConversations() async {
    try {
      final response = await _supabase
          .from('research_conversations')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((conversation) => ResearchConversationModel.fromJson(conversation))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  // Get conversation by ID
  Future<ResearchConversationModel?> getConversationById(String id) async {
    try {
      final response = await _supabase
          .from('research_conversations')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return ResearchConversationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch conversation: $e');
    }
  }

  // Get conversations by researcher ID
  Future<List<ResearchConversationModel>> getConversationsByResearcher(String researcherId) async {
    try {
      final response = await _supabase
          .from('research_conversations')
          .select()
          .eq('researcher_id', researcherId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((conversation) => ResearchConversationModel.fromJson(conversation))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations by researcher: $e');
    }
  }

  // Create new conversation
  Future<ResearchConversationModel> createConversation(ResearchConversationModel conversation) async {
    print('🔍 SERVICE: Starting createConversation');
    print('🔍 SERVICE: Conversation data to insert:');
    
    try {
      final jsonData = conversation.toJson();
      print('🔍 SERVICE: JSON data: $jsonData');
      
      print('🔍 SERVICE: Inserting into Supabase...');
      final response = await _supabase
          .from('research_conversations')
          .insert(jsonData)
          .select()
          .single();
      
      print('✅ SERVICE: Successfully inserted, response: $response');
      return ResearchConversationModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('❌ SERVICE: PostgrestException caught');
      print('❌ SERVICE: Error code: ${e.code}');
      print('❌ SERVICE: Error message: ${e.message}');
      print('❌ SERVICE: Error details: ${e.details}');
      print('❌ SERVICE: Error hint: ${e.hint}');
      throw Exception('Database error: ${e.message} (Code: ${e.code})');
    } catch (e, stackTrace) {
      print('❌ SERVICE: Error during insert');
      print('❌ SERVICE: Error type: ${e.runtimeType}');
      print('❌ SERVICE: Error message: $e');
      print('❌ SERVICE: Stack trace: $stackTrace');
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Update conversation
  Future<ResearchConversationModel> updateConversation(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('research_conversations')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      
      return ResearchConversationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String id) async {
    try {
      await _supabase.from('research_conversations').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Update conversation location data
  Future<ResearchConversationModel> updateLocationData(
    String id,
    Map<String, dynamic> locationData,
  ) async {
    try {
      return await updateConversation(id, {'location_data': locationData});
    } catch (e) {
      throw Exception('Failed to update location data: $e');
    }
  }

  // Update conversation title
  Future<ResearchConversationModel> updateTitle(String id, String title) async {
    try {
      return await updateConversation(id, {'title': title});
    } catch (e) {
      throw Exception('Failed to update title: $e');
    }
  }
}
