import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'map_service.dart';

class FenceAIService {
  final String? _openAIApiKey = dotenv.env['OPENAI_API_KEY'];
  final MapService _mapService = MapService();
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  // Analyze land for development potential
  Future<Map<String, dynamic>> analyzeLandDevelopmentPotential({
    required double latitude,
    required double longitude,
    double? landSize, // in acres or square meters
    String? soilType,
    String? existingVegetation,
    String? waterSources,
    String? landUseHistory,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Get comprehensive location data from Google Maps
      final locationData = await _mapService.getComprehensiveLocationData(
        latitude: latitude,
        longitude: longitude,
      );

      // Build the analysis prompt
      final prompt = _buildAnalysisPrompt(
        locationData: locationData,
        landSize: landSize,
        soilType: soilType,
        existingVegetation: existingVegetation,
        waterSources: waterSources,
        landUseHistory: landUseHistory,
        additionalData: additionalData,
      );

      // Call OpenAI API
      final response = await _callOpenAI(prompt);

      return {
        'success': true,
        'analysis': response,
        'location_data': locationData,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error analyzing land: $e');
    }
  }

  // Quick land assessment (simpler, faster analysis)
  Future<Map<String, dynamic>> quickLandAssessment({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final locationData = await _mapService.getComprehensiveLocationData(
        latitude: latitude,
        longitude: longitude,
      );

      final prompt = '''
Provide a quick assessment of this land location for development potential:

Location: ${locationData['formatted_address']}
City: ${locationData['city']}
State: ${locationData['state']}
Country: ${locationData['country']}
Elevation: ${locationData['elevation']} meters

Nearby Businesses: ${(locationData['nearby_businesses'] as List).take(5).map((b) => b['name']).join(', ')}
Nearby Schools: ${(locationData['nearby_schools'] as List).length} schools within 3km
Nearby Hospitals: ${(locationData['nearby_hospitals'] as List).length} hospitals within 5km

Provide a brief assessment (2-3 paragraphs) covering:
1. General suitability for development
2. Best potential uses
3. Key considerations
''';

      final response = await _callOpenAI(prompt);

      return {
        'success': true,
        'assessment': response,
        'location_data': locationData,
      };
    } catch (e) {
      throw Exception('Error in quick assessment: $e');
    }
  }

  // Generate land development recommendations (similar to TypeScript implementation)
  Future<String> generateLandDevelopmentRecommendations({
    required double latitude,
    required double longitude,
    double? area, // in square meters
    required Map<String, dynamic> enrichedLocationData,
  }) async {
    try {
      final nearbyPlaces = enrichedLocationData['nearby_places'] as List? ?? [];
      final nearbyPlacesText = nearbyPlaces.isEmpty
          ? 'general businesses and establishment found in the area'
          : nearbyPlaces
              .map((place) =>
                  '- Name: ${place['name']}, Types: ${place['types']}, Vicinity: ${place['vicinity']}')
              .join('\n');

      final prompt = '''
Given the following detailed data about a selected location on a map,
analyze it and suggest what kind of infrastructure or development project can be built there.

Latitude: $latitude
Longitude: $longitude
Area: ${area != null ? '$area m²' : 'N/A'}
Formatted Address: ${enrichedLocationData['formatted_address'] ?? 'N/A'}
Location Type: ${enrichedLocationData['is_city_or_village'] ?? 'N/A'}
Main Road Accessibility: ${enrichedLocationData['main_roads'] ?? 'N/A'}

Nearby Businesses and Establishments (within 5km radius):
$nearbyPlacesText

Using the below criteria:
 - Business in the neighboring areas (detailed above)
 - Proximity to village or city (detailed above)
 - Accessibility to main roads (detailed above)
 - Government regulations (AI should infer this based on location type)
 - Environmental impact (AI should infer this)
 - Needs of the local community (AI should infer this based on nearby establishments and location type)
 - Neighboring infrastructure and institutions (detailed above)
 - Establishment (detailed above)
 - Natural features (AI can infer this based on location)
and any other relevant factors.

Give 3 to 5 brief project recommendation for the best project or building that can be developed on the marked area, afterwards explain how to go about the development of each ideas.

If the user tries to include what is outside the scope of land researching,
you should reply with "I can't help you with that. The Model is only built for Land researching"
''';

      final response = await _callOpenAI(prompt);
      return response;
    } catch (e) {
      throw Exception('Error generating land development recommendations: $e');
    }
  }

  // Get specific development recommendations
  Future<Map<String, dynamic>> getSpecificDevelopmentRecommendations({
    required double latitude,
    required double longitude,
    required String developmentType, // e.g., 'residential', 'commercial', 'agricultural', 'mixed-use'
    double? budget,
    String? timeline,
  }) async {
    try {
      final locationData = await _mapService.getComprehensiveLocationData(
        latitude: latitude,
        longitude: longitude,
      );

      final prompt = '''
Analyze this land for ${developmentType.toUpperCase()} development:

Location Details:
- Address: ${locationData['formatted_address']}
- City/Area: ${locationData['city']}, ${locationData['state']}
- Elevation: ${locationData['elevation']} meters
- Coordinates: $latitude, $longitude

Nearby Infrastructure:
- Businesses: ${(locationData['nearby_businesses'] as List).length} within 2km
- Schools: ${(locationData['nearby_schools'] as List).length} within 3km
- Healthcare: ${(locationData['nearby_hospitals'] as List).length} facilities within 5km

${budget != null ? 'Budget: \$$budget' : ''}
${timeline != null ? 'Timeline: $timeline' : ''}

Please provide detailed recommendations for $developmentType development including:
1. Feasibility analysis
2. Recommended project types
3. Market potential
4. Key challenges and solutions
5. Estimated costs and ROI
6. Regulatory considerations
7. Timeline recommendations
8. Risk assessment
''';

      final response = await _callOpenAI(prompt);

      return {
        'success': true,
        'development_type': developmentType,
        'recommendations': response,
        'location_data': locationData,
      };
    } catch (e) {
      throw Exception('Error getting development recommendations: $e');
    }
  }

  // Compare multiple locations
  Future<Map<String, dynamic>> compareLocations({
    required List<Map<String, double>> locations, // List of {latitude, longitude}
    required String purposeOfComparison,
  }) async {
    try {
      final List<Map<String, dynamic>> locationDataList = [];

      for (var location in locations) {
        final data = await _mapService.getComprehensiveLocationData(
          latitude: location['latitude']!,
          longitude: location['longitude']!,
        );
        locationDataList.add(data);
      }

      final prompt = _buildComparisonPrompt(
        locationDataList: locationDataList,
        purpose: purposeOfComparison,
      );

      final response = await _callOpenAI(prompt);

      return {
        'success': true,
        'comparison': response,
        'locations': locationDataList,
      };
    } catch (e) {
      throw Exception('Error comparing locations: $e');
    }
  }

  // Build comprehensive analysis prompt
  String _buildAnalysisPrompt({
    required Map<String, dynamic> locationData,
    double? landSize,
    String? soilType,
    String? existingVegetation,
    String? waterSources,
    String? landUseHistory,
    Map<String, dynamic>? additionalData,
  }) {
    return '''
Perform a comprehensive land development analysis for the following property:

LOCATION INFORMATION:
- Address: ${locationData['formatted_address']}
- City: ${locationData['city']}
- State/Province: ${locationData['state']}
- Country: ${locationData['country']}
- Coordinates: ${locationData['latitude']}, ${locationData['longitude']}
- Elevation: ${locationData['elevation']} meters

LAND CHARACTERISTICS:
${landSize != null ? '- Size: $landSize acres/sq meters' : ''}
${soilType != null ? '- Soil Type: $soilType' : ''}
${existingVegetation != null ? '- Existing Vegetation: $existingVegetation' : ''}
${waterSources != null ? '- Water Sources: $waterSources' : ''}
${landUseHistory != null ? '- Land Use History: $landUseHistory' : ''}

SURROUNDING AREA:
- Nearby Businesses: ${(locationData['nearby_businesses'] as List).take(10).map((b) => b['name']).join(', ')}
- Schools within 3km: ${(locationData['nearby_schools'] as List).length}
- Healthcare facilities within 5km: ${(locationData['nearby_hospitals'] as List).length}

${additionalData != null ? 'ADDITIONAL DATA:\n${additionalData.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}' : ''}

Please provide a detailed analysis including:
1. **Development Potential**: What can this land best be used for?
2. **Recommended Projects**: Specific types of developments that would work well
3. **Market Analysis**: Demand and market conditions in the area
4. **Infrastructure Assessment**: Access to utilities, roads, public transport
5. **Environmental Considerations**: Climate, topography, natural features
6. **Zoning and Regulations**: Likely regulatory requirements
7. **Financial Viability**: Estimated development costs and potential returns
8. **Risk Assessment**: Potential challenges and mitigation strategies
9. **Timeline**: Recommended development phases and duration
10. **Alternative Uses**: Other viable options for the property

Format the response in a clear, structured manner with actionable insights.
''';
  }

  // Build comparison prompt
  String _buildComparisonPrompt({
    required List<Map<String, dynamic>> locationDataList,
    required String purpose,
  }) {
    final locationsText = locationDataList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final data = entry.value;
      return '''
Location $index:
- Address: ${data['formatted_address']}
- City: ${data['city']}, ${data['state']}
- Elevation: ${data['elevation']}m
- Nearby Businesses: ${(data['nearby_businesses'] as List).length}
- Nearby Schools: ${(data['nearby_schools'] as List).length}
- Nearby Hospitals: ${(data['nearby_hospitals'] as List).length}
''';
    }).join('\n');

    return '''
Compare the following locations for: $purpose

$locationsText

Provide a detailed comparison including:
1. Overall ranking with justification
2. Pros and cons of each location
3. Best use case for each location
4. Cost considerations
5. Market potential comparison
6. Infrastructure and accessibility comparison
7. Final recommendation

Be specific and data-driven in your analysis.
''';
  }

  // Call OpenAI API
  Future<String> _callOpenAI(String prompt) async {
    try {
      print('🤖 [FenceAIService] Calling OpenAI API...');
      print('🤖 API Key Present: ${_openAIApiKey != null && _openAIApiKey.isNotEmpty}');
      print('🤖 Prompt Length: ${prompt.length} characters');
      
      final requestBody = {
        'model': 'gpt-4-turbo-preview',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert land development consultant and real estate analyst with extensive knowledge in urban planning, agriculture, commercial development, and environmental assessment. Provide detailed, actionable insights based on location data and land characteristics.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 3000,
      };
      
      print('🤖 Request Body: ${json.encode(requestBody).substring(0, 200)}...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: json.encode(requestBody),
      );

      print('🤖 OpenAI Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('✅ [FenceAIService] OpenAI response received successfully');
        print('✅ Response Length: ${content.length} characters');
        return content;
      } else {
        print('❌ [FenceAIService] OpenAI API error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [FenceAIService] Exception in _callOpenAI: $e');
      throw Exception('Error calling OpenAI API: $e');
    }
  }

  // Stream responses for real-time updates (optional)
  Stream<String> analyzeLandStreaming({
    required double latitude,
    required double longitude,
    double? landSize,
    String? soilType,
  }) async* {
    try {
      final locationData = await _mapService.getComprehensiveLocationData(
        latitude: latitude,
        longitude: longitude,
      );

      final prompt = _buildAnalysisPrompt(
        locationData: locationData,
        landSize: landSize,
        soilType: soilType,
      );

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: json.encode({
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert land development consultant.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'stream': true,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        yield response.body;
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }
}
 