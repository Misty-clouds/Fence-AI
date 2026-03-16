import 'dart:convert';
import 'api_service.dart';

/// Secure MapService that uses server proxy endpoints
/// All Google Maps API calls go through the server to protect API keys
class MapService {
  final ApiService _apiService = ApiService();

  // Get place details from coordinates (using server proxy)
  Future<Map<String, dynamic>> getPlaceDetailsFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final results = await _apiService.geocode(
        latitude: latitude,
        longitude: longitude,
      );

      if (results.isNotEmpty) {
        return _extractLocationData(results[0], latitude, longitude);
      } else {
        throw Exception('No results found for the given coordinates');
      }
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }

  // Get nearby businesses/places (using server proxy)
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 1500,
    String? type,
  }) async {
    try {
      final results = await _apiService.getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
      );

      return results.map((result) {
        final location = result['geometry']['location'];
        return {
          'name': result['name'],
          'vicinity': result['vicinity'],
          'latitude': location['lat'],
          'longitude': location['lng'],
          'place_id': result['place_id'],
          'types': result['types'],
          'rating': result['rating'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error getting nearby places: $e');
    }
  }

  // Get elevation data for the location (using server proxy)
  Future<Map<String, dynamic>> getElevationData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final results = await _apiService.getElevation(
        locations: [
          {'latitude': latitude, 'longitude': longitude}
        ],
      );

      if (results.isNotEmpty) {
        return {
          'elevation': results[0]['elevation'],
          'resolution': results[0]['resolution'],
          'location': results[0]['location'],
        };
      } else {
        throw Exception('No elevation data found');
      }
    } catch (e) {
      throw Exception('Error getting elevation data: $e');
    }
  }

  // Get comprehensive location data (enriched with nearby places and elevation)
  Future<Map<String, dynamic>> getComprehensiveLocationData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('🗺️ [MapService] Getting comprehensive location data...');

      // Get place details
      final placeDetails = await getPlaceDetailsFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      // Get elevation
      final elevationData = await getElevationData(
        latitude: latitude,
        longitude: longitude,
      );

      // Get nearby businesses
      final nearbyBusinesses = await getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: 2000,
      );

      // Get nearby schools
      final nearbySchools = await getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: 3000,
        type: 'school',
      );

      // Get nearby hospitals
      final nearbyHospitals = await getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: 5000,
        type: 'hospital',
      );

      // Combine all data
      return {
        ...placeDetails,
        'elevation': elevationData['elevation'],
        'nearby_businesses': nearbyBusinesses,
        'nearby_schools': nearbySchools,
        'nearby_hospitals': nearbyHospitals,
        'nearby_places': nearbyBusinesses,
      };
    } catch (e) {
      print('❌ [MapService] Error getting comprehensive data: $e');
      throw Exception('Error getting comprehensive location data: $e');
    }
  }

  // Extract location data from geocoding result
  Map<String, dynamic> _extractLocationData(
    Map<String, dynamic> result,
    double latitude,
    double longitude,
  ) {
    final addressComponents = result['address_components'] as List? ?? [];

    String? city;
    String? state;
    String? country;
    String? postalCode;

    for (var component in addressComponents) {
      final types = component['types'] as List;

      if (types.contains('locality')) {
        city = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        state = component['long_name'];
      } else if (types.contains('country')) {
        country = component['long_name'];
      } else if (types.contains('postal_code')) {
        postalCode = component['long_name'];
      }
    }

    return {
      'formatted_address': result['formatted_address'],
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'place_id': result['place_id'],
      'types': result['types'],
      'address_components': addressComponents,
    };
  }
}
