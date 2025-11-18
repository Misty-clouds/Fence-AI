# Google Maps Setup Guide

This document provides instructions for setting up Google Maps in the Fence AI application.

## Prerequisites

1. A Google Cloud Platform account
2. Google Maps API key with the following APIs enabled:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
   - Elevation API

## Environment Setup

### 1. Add your Google Maps API key to `.env` file

Make sure your `.env` file includes:

```env
GOOGLE_MAPS_API_KEY=your_api_key_here
```

### 2. Android Configuration

The Android manifest is already configured with:
- Location permissions (fine, coarse, and background)
- Google Maps API key placeholder (reads from environment)

**Note**: The API key is automatically injected from the `.env` file during build.

### 3. iOS Configuration

The iOS Info.plist is already configured with:
- Location usage descriptions
- Google Maps API key placeholder

**Note**: The API key is automatically injected from the `.env` file during build.

## Features Implemented

### Map Page Features

1. **Interactive Google Map**
   - Displays user's current location
   - Zoom controls (+/- buttons)
   - My Location button
   - Custom map styling

2. **Search Functionality**
   - Text-based location search
   - Search results dropdown
   - Auto-complete suggestions
   - Place selection with automatic camera movement

3. **Draw Mode**
   - Draw polygons on the map
   - Click to add points
   - Visual polygon preview
   - Search within drawn area
   - Clear and reset functionality

4. **Location Details**
   - Comprehensive location information
   - Address details
   - Coordinates display
   - Elevation data
   - Nearby businesses
   - Nearby schools
   - Nearby hospitals
   - Bottom sheet display with scrollable content

5. **Markers**
   - Search result markers
   - Drawing point markers
   - Custom marker icons
   - Info windows

## Map Service API

The `MapService` class provides the following methods:

### Location Data
- `getPlaceDetailsFromCoordinates()` - Get place info from lat/lng
- `searchPlaces()` - Search for places by query
- `getDetailedPlaceInfo()` - Get comprehensive place details
- `getNearbyPlaces()` - Find nearby locations of specific types
- `getElevationData()` - Get elevation for coordinates
- `getComprehensiveLocationData()` - Get all location data at once

## Map Provider State Management

The `MapProvider` uses Riverpod for state management and provides:

### State Properties
- `mapController` - Google Maps controller
- `currentPosition` - User's current location
- `isLoading` - Loading state
- `errorMessage` - Error messages
- `isDrawMode` - Drawing mode state
- `polygonPoints` - Current polygon points
- `polygons` - All drawn polygons
- `markers` - Map markers
- `searchResults` - Search results list
- `selectedLocationData` - Detailed location data

### Methods
- `getCurrentLocation()` - Get user's current position
- `toggleDrawMode()` - Enable/disable drawing
- `addPolygonPoint()` - Add point to polygon
- `clearCurrentDrawing()` - Clear current polygon
- `clearAllPolygons()` - Remove all polygons
- `searchPlaces()` - Search for locations
- `selectSearchResult()` - Select a search result
- `getLocationData()` - Fetch location details
- `searchArea()` - Search within selected area
- `zoomIn()` / `zoomOut()` - Camera zoom controls

## Permissions

### Android
- `ACCESS_FINE_LOCATION` - High accuracy location
- `ACCESS_COARSE_LOCATION` - Approximate location
- `ACCESS_BACKGROUND_LOCATION` - Background location updates
- `INTERNET` - Network access

### iOS
- `NSLocationWhenInUseUsageDescription` - Location while using app
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Always allow location
- `NSLocationAlwaysUsageDescription` - Background location

## Usage Example

```dart
// In your navigation or main app file
import 'package:fence_ai/view/pages/main/map.dart';

// Navigate to map page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MapPage()),
);
```

## Troubleshooting

### Map not displaying
1. Check that your API key is correctly set in `.env`
2. Verify all required APIs are enabled in Google Cloud Console
3. Check Android/iOS build logs for API key errors

### Location not working
1. Ensure location permissions are granted
2. Check device location services are enabled
3. For iOS simulator, set a custom location in Debug menu

### Search not working
1. Verify Places API is enabled
2. Check API key restrictions in Google Cloud Console
3. Review network connectivity

## API Key Security

⚠️ **Important**: Never commit your API key to version control!

1. Add `.env` to `.gitignore`
2. Use environment-specific keys for development and production
3. Restrict API key usage in Google Cloud Console:
   - Set Android app restrictions with package name
   - Set iOS app restrictions with bundle ID
   - Limit API access to only required APIs

## Cost Considerations

Google Maps APIs have usage limits and costs:
- Monitor usage in Google Cloud Console
- Set up billing alerts
- Implement caching where appropriate
- Consider rate limiting for production

## Next Steps

To extend the map functionality, you can:
1. Add custom map styles
2. Implement clustering for multiple markers
3. Add traffic layer
4. Implement route planning
5. Add geofencing capabilities
6. Integrate with property data
7. Add heatmap visualization
8. Implement offline map caching
