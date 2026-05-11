import 'api_service.dart';

class LandComparisonService {
  final ApiService _apiService = ApiService();

  Future<String> compareLands({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String comparisonCriteria,
  }) async {
    try {
      final prompt = _buildComparisonPrompt(
        land1: land1,
        land2: land2,
        criteria: comparisonCriteria,
      );

      final result = await _apiService.callAI(
        messages: [
          {
            'role': 'system',
            'content':
                '''You are Fense AI, an expert land comparison and analysis consultant.
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
          {'role': 'user', 'content': prompt},
        ],
        model: 'gpt-4-turbo-preview',
        temperature: 0.7,
      );

      final aiResponse = result['choices'][0]['message']['content'] as String;

      return _formatComparisonResponse(
        land1: land1,
        land2: land2,
        criteria: comparisonCriteria,
        aiResponse: aiResponse,
      );
    } catch (e) {
      rethrow;
    }
  }

  String _buildComparisonPrompt({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String criteria,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Please compare the following two land plots based on this criteria: **$criteria**\n',
    );

    buffer.writeln('## Land 1 Details:');
    buffer.writeln('- **Location**: ${land1['address'] ?? 'Not specified'}');
    buffer.writeln(
      '- **Coordinates**: Lat ${land1['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng ${land1['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
    );
    buffer.writeln(
      '- **Land Size**: ${(land1['area'] ?? 0.0).toStringAsFixed(2)} acres',
    );
    if (land1['polygon_points'] != null &&
        (land1['polygon_points'] as List).isNotEmpty) {
      buffer.writeln(
        '- **Shape**: Polygon with ${(land1['polygon_points'] as List).length} points',
      );
    }

    buffer.writeln();

    buffer.writeln('## Land 2 Details:');
    buffer.writeln('- **Location**: ${land2['address'] ?? 'Not specified'}');
    buffer.writeln(
      '- **Coordinates**: Lat ${land2['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng ${land2['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
    );
    buffer.writeln(
      '- **Land Size**: ${(land2['area'] ?? 0.0).toStringAsFixed(2)} acres',
    );
    if (land2['polygon_points'] != null &&
        (land2['polygon_points'] as List).isNotEmpty) {
      buffer.writeln(
        '- **Shape**: Polygon with ${(land2['polygon_points'] as List).length} points',
      );
    }

    buffer.writeln();
    buffer.writeln(
      'Please provide a detailed comparison focusing on: $criteria',
    );
    buffer.writeln();
    buffer.writeln('Include:');
    buffer.writeln('1. Side-by-side comparison of key metrics');
    buffer.writeln('2. Strengths and weaknesses of each land');
    buffer.writeln('3. Suitability analysis based on the specified criteria');
    buffer.writeln('4. Final recommendation with reasoning');

    return buffer.toString();
  }

  String _formatComparisonResponse({
    required Map<String, dynamic> land1,
    required Map<String, dynamic> land2,
    required String criteria,
    required String aiResponse,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('# 🔍 Land Comparison Analysis\n');
    buffer.writeln('---\n');
    buffer.writeln('## 📋 Comparison Criteria');
    buffer.writeln('**$criteria**\n');
    buffer.writeln('---\n');
    buffer.writeln('## 📊 Quick Overview\n');

    buffer.writeln('### 🏞️ Land 1');
    buffer.writeln('- **Location**: ${land1['address'] ?? 'Not specified'}');
    buffer.writeln(
      '- **Size**: **${(land1['area'] ?? 0.0).toStringAsFixed(2)} acres**',
    );
    buffer.writeln(
      '- **Coordinates**: ${land1['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${land1['longitude']?.toStringAsFixed(4) ?? 'N/A'}\n',
    );

    buffer.writeln('### 🏞️ Land 2');
    buffer.writeln('- **Location**: ${land2['address'] ?? 'Not specified'}');
    buffer.writeln(
      '- **Size**: **${(land2['area'] ?? 0.0).toStringAsFixed(2)} acres**',
    );
    buffer.writeln(
      '- **Coordinates**: ${land2['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${land2['longitude']?.toStringAsFixed(4) ?? 'N/A'}\n',
    );

    buffer.writeln('---\n');
    buffer.writeln('## 🤖 Detailed Analysis\n');
    buffer.writeln(aiResponse);
    buffer.writeln('\n---\n');
    buffer.writeln(
      '*Analysis generated by Fense AI - Your expert land research assistant*',
    );

    return buffer.toString();
  }
}
