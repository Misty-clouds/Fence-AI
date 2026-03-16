import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API service for secure server communication
/// All API keys are stored on the server side for security
class ApiService {
  final String _serverUrl;

  ApiService() : _serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:3000';

  /// Call OpenAI API through server proxy
  Future<Map<String, dynamic>> callAI({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4-turbo-preview',
    double temperature = 0.7,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': messages,
          'model': model,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Server error: ${data['error']}');
        }
      } else {
        throw Exception('Server API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling AI API: $e');
    }
  }

  /// Geocode coordinates to address through server proxy
  Future<List<dynamic>> geocode({
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      final params = <String, String>{};
      if (latitude != null && longitude != null) {
        params['latlng'] = '$latitude,$longitude';
      }
      if (address != null) {
        params['address'] = address;
      }

      final uri = Uri.parse('$_serverUrl/api/maps/geocode')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        } else {
          throw Exception('Server error: ${data['error']}');
        }
      } else {
        throw Exception('Server API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling geocode API: $e');
    }
  }

  /// Get nearby places through server proxy
  Future<List<dynamic>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    String? type,
    String? keyword,
    int radius = 5000,
  }) async {
    try {
      final params = <String, String>{
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
      };
      if (type != null) params['type'] = type;
      if (keyword != null) params['keyword'] = keyword;

      final uri = Uri.parse('$_serverUrl/api/maps/places')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        } else {
          throw Exception('Server error: ${data['error']}');
        }
      } else {
        throw Exception('Server API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling places API: $e');
    }
  }

  /// Get elevation data through server proxy
  Future<List<dynamic>> getElevation({
    required List<Map<String, double>> locations,
  }) async {
    try {
      final locationsParam = locations
          .map((loc) => '${loc['latitude']},${loc['longitude']}')
          .join('|');

      final uri = Uri.parse('$_serverUrl/api/maps/elevation')
          .replace(queryParameters: {'locations': locationsParam});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        } else {
          throw Exception('Server error: ${data['error']}');
        }
      } else {
        throw Exception('Server API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling elevation API: $e');
    }
  }

  /// Get server URL for reference
  String get serverUrl => _serverUrl;
}
