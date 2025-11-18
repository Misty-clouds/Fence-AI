import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fence_ai/core/services/map_service.dart';
import 'package:fence_ai/constants/map_style.dart';

// Provider for MapProvider
final mapProvider = ChangeNotifierProvider<MapProvider>((ref) {
  return MapProvider();
});

class MapProvider extends ChangeNotifier {
  final MapService _mapService = MapService();
  
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  // Map state
  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // Default: San Francisco
  LatLng get currentPosition => _currentPosition;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Draw mode state
  bool _isDrawMode = false;
  bool get isDrawMode => _isDrawMode;

  List<LatLng> _polygonPoints = [];
  List<LatLng> get polygonPoints => _polygonPoints;

  Set<Polygon> _polygons = {};
  Set<Polygon> get polygons => _polygons;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> get searchResults => _searchResults;

  // Selected location data
  Map<String, dynamic>? _selectedLocationData;
  Map<String, dynamic>? get selectedLocationData => _selectedLocationData;

  // Camera position
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 14.0,
  );
  CameraPosition get cameraPosition => _cameraPosition;

  // Initialize map controller
  void onMapCreated(GoogleMapController controller) {
    print('🗺️ Map controller created');
    _mapController = controller;
    // Apply custom map style
    try {
      _mapController?.setMapStyle(mapStyle);
      print('✅ Map style applied successfully');
    } catch (e) {
      print('⚠️ Error applying map style: $e');
    }
    notifyListeners();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    print('📍 Getting current location...');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔐 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        print('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        _errorMessage = 'Location permissions are permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('📍 Getting device position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('✅ Position obtained: ${position.latitude}, ${position.longitude}');
      _currentPosition = LatLng(position.latitude, position.longitude);
      _cameraPosition = CameraPosition(
        target: _currentPosition,
        zoom: 15.0,
      );
      
      // Move camera to current position
      print('📷 Moving camera to current position...');
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_cameraPosition),
      );

      _isLoading = false;
      notifyListeners();
      print('✅ Location successfully set');
    } catch (e) {
      print('❌ Error getting location: $e');
      _errorMessage = 'Error getting location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle draw mode
  void toggleDrawMode() {
    _isDrawMode = !_isDrawMode;
    if (!_isDrawMode && _polygonPoints.isNotEmpty) {
      // Finish drawing
      _finishDrawing();
    } else if (!_isDrawMode) {
      // Cancel drawing
      _polygonPoints.clear();
    }
    notifyListeners();
  }

  // Add point to polygon
  void addPolygonPoint(LatLng point) {
    if (_isDrawMode) {
      _polygonPoints.add(point);
      notifyListeners();
    }
  }

  // Finish drawing polygon
  void _finishDrawing() {
    if (_polygonPoints.length >= 3) {
      final polygon = Polygon(
        polygonId: PolygonId('polygon_${DateTime.now().millisecondsSinceEpoch}'),
        points: List.from(_polygonPoints),
        fillColor: const Color(0xFF3A6E57).withOpacity(0.3),
        strokeColor: const Color(0xFF3A6E57),
        strokeWidth: 3,
        consumeTapEvents: true,
      );
      _polygons.add(polygon);
    }
    _polygonPoints.clear();
    notifyListeners();
  }

  // Clear current drawing
  void clearCurrentDrawing() {
    _polygonPoints.clear();
    _isDrawMode = false;
    notifyListeners();
  }

  // Clear all polygons
  void clearAllPolygons() {
    _polygons.clear();
    _polygonPoints.clear();
    _isDrawMode = false;
    notifyListeners();
  }

  // Search for places
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _searchResults = await _mapService.searchPlaces(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error searching places: $e';
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a search result
  Future<void> selectSearchResult(Map<String, dynamic> result) async {
    try {
      final lat = result['latitude'] as double;
      final lng = result['longitude'] as double;
      final location = LatLng(lat, lng);

      // Move camera to selected location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15.0,
          ),
        ),
      );

      // Add marker
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('selected_${result['place_id']}'),
          position: location,
          infoWindow: InfoWindow(
            title: result['name'],
            snippet: result['formatted_address'],
          ),
        ),
      );

      _searchResults = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error selecting location: $e';
      notifyListeners();
    }
  }

  // Get location data for a specific point
  Future<void> getLocationData(LatLng location) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedLocationData = await _mapService.getComprehensiveLocationData(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting location data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search area (polygon or circle)
  Future<void> searchArea(LatLng center) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get comprehensive location data
      await getLocationData(center);

      // Add marker at center
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('search_center'),
          position: center,
          infoWindow: InfoWindow(
            title: _selectedLocationData?['city'] ?? 'Selected Location',
            snippet: _selectedLocationData?['formatted_address'] ?? '',
          ),
        ),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error searching area: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Zoom in
  void zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  // Zoom out
  void zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  // Update camera position
  void updateCameraPosition(CameraPosition position) {
    _cameraPosition = position;
    notifyListeners();
  }

  // Clear markers
  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  // Clear selected location data
  void clearSelectedLocationData() {
    _selectedLocationData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
