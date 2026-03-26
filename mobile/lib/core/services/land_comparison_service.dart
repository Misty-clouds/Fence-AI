import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LandComparisonService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Compares two lands based on provided criteria
  /// Returns formatted markdown response with comparison analysis
  Future<String> compareLands({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String comparisonCriteria,
  }) async {
    try {
      print('🔄 Starting land comparison...');
      print('📍 Land 1: ${land1['address']}, Area: ${land1['area']} acres');
      print('📍 Land 2: ${land2['address']}, Area: ${land2['area']} acres');
      print('📝 Criteria: $comparisonCriteria');

      // Build the comparison prompt
      final prompt = _buildComparisonPrompt(
        land1: land1,
        land2: land2,
        criteria: comparisonCriteria,
      );

      final requestBody = {
        'model': 'gpt-4-turbo-preview',
        'messages': [
          {
            'role': 'system',
            'content': '''You are Fense AI, an expert land comparison and analysis consultant. 
Your role is to provide comprehensive, objective comparisons between two land plots based on specific criteria.

When comparing lands:
1. Be thorough and data-driven in your analysis
2. Consider multiple factors: location, size, topography, accessibility, development potential, soil quality, zoning, market value, etc.
3. Provide clear pros and cons for each land
4. Give actionable recommendations based on the comparison criteria
5. Use clear headings and bullet points for easy reading
6. Be objective and highlight trade-offs

Format your response in markdown with:
- Clear section headers (## Land 1 vs Land 2)
- Comparison tables when appropriate
- Bold text for key findings
- Bullet points for detailed analysis
- A final recommendation section

Always maintain a professional, informative tone.'''
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
      };

      print('📡 Sending request to OpenAI API...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - please try again');
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        
        print('✅ Comparison generated successfully');
        print('📊 Response length: ${aiResponse.length} characters');

        // Build the final formatted response
        final formattedResponse = _formatComparisonResponse(
          land1: land1,
          land2: land2,
          criteria: comparisonCriteria,
          aiResponse: aiResponse,
        );

        return formattedResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication error');
        throw Exception('API authentication failed - please check API key');
      } else if (response.statusCode == 429) {
        print('❌ Rate limit exceeded');
        throw Exception('Too many requests - please wait a moment and try again');
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw Exception('Server error - please try again later');
      } else {
        print('❌ Unexpected error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to generate comparison: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in compareLands: $e');
      rethrow;
    }
  }

  /// Builds the comparison prompt for the AI
  String _buildComparisonPrompt({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String criteria,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Please compare the following two land plots based on this criteria: **$criteria**\n');
    
    buffer.writeln('## Land 1 Details:');
    buffer.writeln('- **Location**: ${land1['address'] ?? 'Not specified'}');
    buffer.writeln('- **Coordinates**: Lat ${land1['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng ${land1['longitude']?.toStringAsFixed(4) ?? 'N/A'}');
    buffer.writeln('- **Land Size**: ${(land1['area'] ?? 0.0).toStringAsFixed(2)} acres');
    
    if (land1['polygon_points'] != null && (land1['polygon_points'] as List).isNotEmpty) {
      buffer.writeln('- **Shape**: Polygon with ${(land1['polygon_points'] as List).length} points');
    }
    
    buffer.writeln();
    
    buffer.writeln('## Land 2 Details:');
    buffer.writeln('- **Location**: ${land2['address'] ?? 'Not specified'}');
    buffer.writeln('- **Coordinates**: Lat ${land2['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng ${land2['longitude']?.toStringAsFixed(4) ?? 'N/A'}');
    buffer.writeln('- **Land Size**: ${(land2['area'] ?? 0.0).toStringAsFixed(2)} acres');
    
    if (land2['polygon_points'] != null && (land2['polygon_points'] as List).isNotEmpty) {
      buffer.writeln('- **Shape**: Polygon with ${(land2['polygon_points'] as List).length} points');
    }
    
    buffer.writeln();
    buffer.writeln('Please provide a detailed comparison focusing on: $criteria');
    buffer.writeln();
    buffer.writeln('Include:');
    buffer.writeln('1. Side-by-side comparison of key metrics');
    buffer.writeln('2. Strengths and weaknesses of each land');
    buffer.writeln('3. Suitability analysis based on the specified criteria');
    buffer.writeln('4. Final recommendation with reasoning');

    return buffer.toString();
  }

  /// Formats the final comparison response with headers
  String _formatComparisonResponse({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String criteria,
    required String aiResponse,
  }) {
    final buffer = StringBuffer();

    // Header section
    buffer.writeln('# 🔍 Land Comparison Analysis\n');
    buffer.writeln('---\n');
    
    // Comparison criteria
    buffer.writeln('## 📋 Comparison Criteria');
    buffer.writeln('**$criteria**\n');
    buffer.writeln('---\n');
    
    // Quick overview
    buffer.writeln('## 📊 Quick Overview\n');
    
    buffer.writeln('### 🏞️ Land 1');
    buffer.writeln('- **Location**: ${land1['address'] ?? 'Not specified'}');
    buffer.writeln('- **Size**: **${(land1['area'] ?? 0.0).toStringAsFixed(2)} acres**');
    buffer.writeln('- **Coordinates**: ${land1['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${land1['longitude']?.toStringAsFixed(4) ?? 'N/A'}\n');
    
    buffer.writeln('### 🏞️ Land 2');
    buffer.writeln('- **Location**: ${land2['address'] ?? 'Not specified'}');
    buffer.writeln('- **Size**: **${(land2['area'] ?? 0.0).toStringAsFixed(2)} acres**');
    buffer.writeln('- **Coordinates**: ${land2['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${land2['longitude']?.toStringAsFixed(4) ?? 'N/A'}\n');
    
    buffer.writeln('---\n');
    
    // AI analysis
    buffer.writeln('## 🤖 Detailed Analysis\n');
    buffer.writeln(aiResponse);
    
    buffer.writeln('\n---\n');
    buffer.writeln('*Analysis generated by Fense AI - Your expert land research assistant*');

    return buffer.toString();
  }
}
