import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapService {
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  // Get place details from coordinates
  Future<Map<String, dynamic>> getPlaceDetailsFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return _extractLocationData(data['results'][0], latitude, longitude);
        } else {
          throw Exception('No results found for the given coordinates');
        }
      } else {
        throw Exception('Failed to fetch location details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }

  // Search for a place by query
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((result) {
            final location = result['geometry']['location'];
            return {
              'name': result['name'],
              'formatted_address': result['formatted_address'],
              'latitude': location['lat'],
              'longitude': location['lng'],
              'place_id': result['place_id'],
              'types': result['types'],
            };
          }).toList();
        } else {
          throw Exception('No results found for query: $query');
        }
      } else {
        throw Exception('Failed to search places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  // Get detailed place information including nearby businesses
  Future<Map<String, dynamic>> getDetailedPlaceInfo(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry,address_components,types,vicinity&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          return _extractLocationData(result, location['lat'], location['lng']);
        } else {
          throw Exception('Failed to get place details');
        }
      } else {
        throw Exception('Failed to fetch place info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting detailed place info: $e');
    }
  }

  // Get nearby businesses/places
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 1500, // in meters
    String? type, // e.g., 'restaurant', 'school', 'hospital'
  }) async {
    try {
      final typeParam = type != null ? '&type=$type' : '';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius$typeParam&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((result) {
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
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch nearby places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting nearby places: $e');
    }
  }

  // Get elevation data for the location
  Future<Map<String, dynamic>> getElevationData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/elevation/json?locations=$latitude,$longitude&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return {
            'elevation': data['results'][0]['elevation'],
            'resolution': data['results'][0]['resolution'],
          };
        } else {
          throw Exception('Failed to get elevation data');
        }
      } else {
        throw Exception('Failed to fetch elevation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting elevation data: $e');
    }
  }

  // Get comprehensive location analysis data
  Future<Map<String, dynamic>> getComprehensiveLocationData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get basic location details
      final locationDetails = await getPlaceDetailsFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      // Get elevation data
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

      return {
        ...locationDetails,
        'elevation': elevationData['elevation'],
        'nearby_businesses': nearbyBusinesses,
        'nearby_schools': nearbySchools,
        'nearby_hospitals': nearbyHospitals,
        'coordinates': {
          'latitude': latitude,
          'longitude': longitude,
        },
      };
    } catch (e) {
      throw Exception('Error getting comprehensive location data: $e');
    }
  }

  // Get enriched location data for AI analysis (similar to the TypeScript implementation)
  Future<Map<String, dynamic>> getEnrichedLocationDataForAI({
    required double latitude,
    required double longitude,
    double? area, // in square meters
  }) async {
    try {
      print('🗺️ [MapService] Getting enriched location data for AI...');
      print('🗺️ Coordinates: $latitude, $longitude');
      print('🗺️ Area: $area sqm');
      
      // 1. Get exact location details (address, city/village type) using Geocoding API
      final geocodeUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
      );
      print('🗺️ Calling Geocoding API...');
      final geocodeResponse = await http.get(geocodeUrl);
      final geocodeData = json.decode(geocodeResponse.body);
      print('🗺️ Geocoding API Status: ${geocodeData['status']}');

      Map<String, dynamic> locationDetails = {};
      
      if (geocodeData['status'] == 'OK' && (geocodeData['results'] as List).isNotEmpty) {
        final addressComponents = geocodeData['results'][0]['address_components'] as List;
        final formattedAddress = geocodeData['results'][0]['formatted_address'];

        String? city;
        String? village;
        List<String> roadAccessibility = [];

        for (var component in addressComponents) {
          final types = component['types'] as List;
          
          if (types.contains('locality')) {
            city = component['long_name'];
          } else if (types.contains('sublocality') || types.contains('neighborhood')) {
            village = component['long_name'];
          } else if (types.contains('route') || types.contains('highway')) {
            roadAccessibility.add(component['long_name']);
          }
        }

        locationDetails = {
          'formatted_address': formattedAddress,
          'city': city ?? village,
          'is_city_or_village': city != null ? 'city' : (village != null ? 'village' : 'unknown'),
          'main_roads': roadAccessibility.isNotEmpty 
              ? roadAccessibility.join(', ') 
              : 'No major roads identified nearby.',
        };
        print('✅ Location details extracted: ${locationDetails['city']}');
      }

      // 2. Get nearby businesses and establishments using Nearby Search API
      final nearbyPlaces = <Map<String, dynamic>>[];
      final nearbySearchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&key=$_apiKey',
      );
      print('🗺️ Calling Nearby Search API (5km radius)...');
      final nearbySearchResponse = await http.get(nearbySearchUrl);
      final nearbySearchData = json.decode(nearbySearchResponse.body);
      print('🗺️ Nearby Search API Status: ${nearbySearchData['status']}');

      if (nearbySearchData['status'] == 'OK' && (nearbySearchData['results'] as List).isNotEmpty) {
        for (var place in nearbySearchData['results']) {
          nearbyPlaces.add({
            'name': place['name'],
            'types': (place['types'] as List).join(', '),
            'vicinity': place['vicinity'],
          });
        }
        print('✅ Found ${nearbyPlaces.length} nearby places');
      }

      final result = {
        'latitude': latitude,
        'longitude': longitude,
        'area': area,
        ...locationDetails,
        'nearby_places': nearbyPlaces,
      };
      
      print('✅ [MapService] Enriched location data complete');
      return result;
    } catch (e) {
      print('❌ [MapService] Error getting enriched location data: $e');
      throw Exception('Error getting enriched location data: $e');
    }
  }

  // Extract and structure location data
  Map<String, dynamic> _extractLocationData(
    Map<String, dynamic> result,
    double latitude,
    double longitude,
  ) {
    final addressComponents = result['address_components'] as List? ?? [];
    
    String? country;
    String? state;
    String? city;
    String? locality;
    String? postalCode;
    String? route;

    for (var component in addressComponents) {
      final types = component['types'] as List;
      
      if (types.contains('country')) {
        country = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        state = component['long_name'];
      } else if (types.contains('locality')) {
        city = component['long_name'];
      } else if (types.contains('sublocality') || types.contains('sublocality_level_1')) {
        locality = component['long_name'];
      } else if (types.contains('postal_code')) {
        postalCode = component['long_name'];
      } else if (types.contains('route')) {
        route = component['long_name'];
      }
    }

    return {
      'formatted_address': result['formatted_address'],
      'country': country,
      'state': state,
      'city': city ?? locality,
      'locality': locality,
      'postal_code': postalCode,
      'route': route,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': result['place_id'],
      'types': result['types'] ?? [],
    };
  }
}
