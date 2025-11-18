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
          'content': '''You are Fense AI, an expert land research and development consultant. You help users understand and analyze land for various purposes.

Your scope includes ANYTHING related to land, housing, and property:
- Land analysis and site evaluation
- Agricultural land assessment and farming practices
- Soil types, quality, and suitability for different uses
- Drainage systems and water management
- Land infrastructure (roads, bridges, utilities)
- Zoning regulations and land use planning
- Construction feasibility and site preparation
- Topography and terrain analysis
- Environmental impact and sustainability
- Land surveying and measurements
- Property boundaries and land rights
- Urban planning and development
- Real estate (buying, selling, investment, valuation, market analysis)
- Housing development and residential projects
- Commercial property development
- Green energy and renewable energy projects on land (solar farms, wind farms, etc.)
- Land use for sustainability and environmental conservation
- Building codes and regulations
- Property management and maintenance
- Land financing and investment strategies

STRICT RULES:
1. ONLY answer questions related to land, housing, property, real estate, and their applications
2. If asked about topics completely unrelated to land/property (like sports, entertainment, general technology, food recipes, etc.), respond: "I specialize in land, property, and real estate topics. Please ask me about land analysis, housing development, real estate investment, agricultural use, infrastructure, zoning, or any land-related questions."
3. Maintain context from previous messages in this conversation
4. When mentioning specific locations or addresses, use this format: [LOCATION: City/Area Name | Latitude,Longitude]
5. Be helpful, professional, and provide actionable insights
6. If you need more details about the land or property being discussed, ask clarifying questions

Remember: If it relates to LAND, HOUSING, PROPERTY, or REAL ESTATE in any way, you can help. Reject only topics with NO connection to land or property.'''
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
