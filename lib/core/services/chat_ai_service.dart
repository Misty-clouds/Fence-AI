import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  final String _apiKey;

  ChatAIService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Generate AI response for continued chat about land, agriculture, and real estate
  /// Returns both the response text and detected locations (if any)
  Future<Map<String, dynamic>> generateChatResponse({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    try {
      print('💬 ============ CHAT AI SERVICE ============');
      print('💬 User Message: $userMessage');
      print('💬 History Length: ${conversationHistory.length} messages');

      // Prepare messages for OpenAI
      final messages = [
        {
          'role': 'system',
          'content': '''You are Fense AI, an expert assistant specializing in land development, agriculture, and real estate. 

Your scope is LIMITED to:
- Land analysis and development recommendations
- Agricultural practices and farming opportunities
- Real estate market insights and property evaluation
- Zoning regulations and land use planning
- Sustainable land management
- Investment opportunities in land and property

IMPORTANT INSTRUCTIONS:
1. ONLY answer questions related to land, agriculture, and real estate
2. If asked about topics outside your scope, politely redirect: "I specialize in land, agriculture, and real estate topics. Please ask me about land development, farming, property investment, or related subjects."
3. When mentioning specific locations or addresses, use this EXACT format:
   [LOCATION: City/Area Name | Latitude,Longitude]
   Example: [LOCATION: Lagos Island | 6.4541,3.3947]
4. You can mention multiple locations in one response
5. Be conversational but professional
6. Provide actionable insights and recommendations
7. If you don't have enough context, ask clarifying questions

Remember: Your expertise is land, agriculture, and real estate. Stay within this scope.'''
        },
        ...conversationHistory,
        {
          'role': 'user',
          'content': userMessage,
        }
      ];

      final response = await _callOpenAI(messages);
      
      // Extract locations from response
      final locations = _extractLocations(response);
      
      print('💬 Response generated: ${response.length} characters');
      print('💬 Locations detected: ${locations.length}');
      print('💬 ======================================');

      return {
        'response': response,
        'locations': locations,
        'has_locations': locations.isNotEmpty,
      };
    } catch (e, stackTrace) {
      print('❌ Error in chat AI service: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Extract locations from AI response
  /// Format: [LOCATION: Name | Lat,Lng]
  List<Map<String, dynamic>> _extractLocations(String text) {
    final locations = <Map<String, dynamic>>[];
    final regex = RegExp(r'\[LOCATION:\s*([^\|]+)\|\s*([\d\.-]+),([\d\.-]+)\]');
    
    final matches = regex.allMatches(text);
    for (final match in matches) {
      final name = match.group(1)?.trim();
      final lat = double.tryParse(match.group(2)?.trim() ?? '');
      final lng = double.tryParse(match.group(3)?.trim() ?? '');
      
      if (name != null && lat != null && lng != null) {
        locations.add({
          'name': name,
          'latitude': lat,
          'longitude': lng,
        });
      }
    }
    
    return locations;
  }

  /// Remove location markers from text for clean display
  String cleanResponseText(String text) {
    return text.replaceAll(
      RegExp(r'\[LOCATION:\s*[^\]]+\]'),
      '',
    ).trim();
  }

  /// Call OpenAI API
  Future<String> _callOpenAI(List<Map<String, dynamic>> messages) async {
    try {
      print('🤖 Calling OpenAI Chat API...');
      
      final requestBody = {
        'model': 'gpt-4-turbo-preview',
        'messages': messages,
        'max_tokens': 2000,
        'temperature': 0.7,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      };

      print('📤 Request Body: ${jsonEncode(requestBody).substring(0, 500)}...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('✅ OpenAI response received: ${content.length} characters');
        return content;
      } else {
        print('❌ OpenAI API error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error calling OpenAI: $e');
      rethrow;
    }
  }

  /// Build conversation history from messages
  static List<Map<String, dynamic>> buildConversationHistory(
    List<dynamic> messages, {
    int maxMessages = 10,
  }) {
    // Take last N messages to stay within token limits
    final recentMessages = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;

    return recentMessages.map((msg) {
      final isUser = msg.messageType.toString().contains('sent');
      return {
        'role': isUser ? 'user' : 'assistant',
        'content': msg.content ?? '',
      };
    }).toList();
  }
}
