import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatAIService {
  // Use server proxy endpoint for secure API key handling
  final String _serverUrl;

  ChatAIService()
    : _serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:3000';

  /// Generate AI response for continued chat about land, agriculture, and real estate
  /// Returns both the response text and detected locations (if any)
  Future<Map<String, dynamic>> generateChatResponse({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    try {
      // Prepare messages for OpenAI
      final messages = [
        {
          'role': 'system',
          'content':
              '''You are Fense AI, an expert land research and development consultant. You help users understand and analyze land for various purposes.

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

Remember: If it relates to LAND, HOUSING, PROPERTY, or REAL ESTATE in any way, you can help. Reject only topics with NO connection to land or property.''',
        },
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await _callOpenAI(messages);

      // Extract locations from response
      final locations = _extractLocations(response);

      return {
        'response': response,
        'locations': locations,
        'has_locations': locations.isNotEmpty,
      };
    } catch (e, stackTrace) {
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
        locations.add({'name': name, 'latitude': lat, 'longitude': lng});
      }
    }

    return locations;
  }

  /// Remove location markers from text for clean display
  String cleanResponseText(String text) {
    return text.replaceAll(RegExp(r'\[LOCATION:\s*[^\]]+\]'), '').trim();
  }

  /// Call server AI proxy endpoint (secure)
  Future<String> _callOpenAI(List<Map<String, dynamic>> messages) async {
    try {
      print('🤖 Calling server AI proxy...');

      final requestBody = {
        'messages': messages,
        'model': 'gpt-4-turbo-preview',
        'temperature': 0.7,
      };

      final response = await http.post(
        Uri.parse('$_serverUrl/api/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final content = data['data']['content'] as String;
          return content;
        } else {
          throw Exception('Server error: ${data['error']}');
        }
      } else {
        throw Exception(
          'Server API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
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
