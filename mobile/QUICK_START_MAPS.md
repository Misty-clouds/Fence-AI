# Quick Start Guide - Google Maps Integration

## Prerequisites
✅ Flutter installed
✅ Google Cloud Platform account
✅ Google Maps API key

## 5-Minute Setup

### Step 1: Get Your API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
   - Elevation API
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

### Step 2: Add API Key to Project
1. Open `.env` file in project root
2. Add or update this line:
   ```env
   GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
   ```
3. Save the file

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run the App
```bash
# For Android
flutter run

# For iOS (first time only)
cd ios && pod install && cd ..
flutter run
```

### Step 5: Grant Permissions
When the app launches:
1. Allow location permissions when prompted
2. Navigate to the Map page
3. Start exploring!

## Using the Map Features

### Search for a Location
1. Tap the search bar at the top
2. Type any address or place name
3. Select from the results
4. View location details in the bottom sheet

### Draw on the Map
1. Tap "Draw to search" button at the bottom
2. Tap on the map to add points (minimum 3)
3. Tap the search icon to get area information
4. Tap X to cancel drawing

### Navigate the Map
- **Zoom In/Out**: Use + and - buttons on the left
- **My Location**: Tap the location icon to center on your position
- **Pan**: Drag the map with your finger
- **Pinch**: Pinch to zoom (mobile devices)

## Troubleshooting

### Map Shows Gray Screen
- **Cause**: Invalid or missing API key
- **Fix**: Check your `.env` file and verify API key is correct

### "Location Permission Denied"
- **Cause**: App doesn't have location access
- **Fix**: Go to device Settings → Apps → Fence AI → Permissions → Enable Location

### Search Not Working
- **Cause**: Places API not enabled or API key restrictions
- **Fix**: 
  1. Enable Places API in Google Cloud Console
  2. Check API key restrictions allow your app

### Build Errors on iOS
- **Cause**: Pods not installed
- **Fix**: Run `cd ios && pod install && cd ..`

## API Key Security Tips

⚠️ **Important Security Notes:**

1. **Never commit API key to Git**
   - Ensure `.env` is in `.gitignore`
   - Use different keys for dev/production

2. **Set API Key Restrictions**
   - Go to Google Cloud Console
   - Edit your API key
   - Add application restrictions:
     - **Android**: Add package name `com.example.fence_ai`
     - **iOS**: Add bundle ID from Xcode
   - Add API restrictions (only enable APIs you use)

3. **Monitor Usage**
   - Set up billing alerts in Google Cloud
   - Review usage regularly
   - Implement rate limiting if needed

## Cost Management

Google Maps APIs have a **free tier**:
- $200 monthly credit
- Covers ~28,000 map loads
- Monitor usage in Google Cloud Console

**Tips to minimize costs:**
- Enable only required APIs
- Implement caching where possible
- Use API key restrictions
- Set up billing alerts

## Getting Help

- **Setup Issues**: See `GOOGLE_MAPS_SETUP.md`
- **User Guide**: See `MAP_USER_GUIDE.md`
- **Implementation Details**: See `MAP_IMPLEMENTATION_SUMMARY.md`

## What's Included

✅ Interactive Google Maps
✅ Location search with autocomplete
✅ Draw polygons to search areas
✅ Zoom and navigation controls
✅ Current location tracking
✅ Detailed location information
✅ Nearby businesses, schools, hospitals
✅ Elevation data
✅ Custom map styling (brand colors)
✅ Error handling
✅ Loading states
✅ Responsive design

## Next Steps

Once the basic setup is complete, you can:
1. Customize map styling in `lib/constants/map_style.dart`
2. Add more search filters in `MapService`
3. Integrate with property listings
4. Add user preferences
5. Implement offline caching

Happy mapping! 🗺️
