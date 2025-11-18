import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fence_ai/core/providers/map_provider.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/widgets/location_details_sheet.dart';
import 'package:fence_ai/view/widgets/side_bar.dart';
import 'package:fence_ai/view/widgets/ai_analysis_loading_dialog.dart';
import 'package:fence_ai/view/pages/main/research_chat.dart';
import 'package:fence_ai/core/providers/providers.dart';
import 'package:fence_ai/core/services/map_service.dart';
import 'package:fence_ai/core/services/fence_ai_service.dart';
import 'package:fence_ai/core/models/research_messages_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class MapPage extends ConsumerStatefulWidget {
  final String? conversationId;
  
  const MapPage({super.key, this.conversationId});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('🗺️ MapPage: initState called');
    print('🗺️ MapPage: Conversation ID: ${widget.conversationId}');
    // Get current location on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🗺️ MapPage: Post frame callback executing');
      final provider = ref.read(mapProvider);
      // Reset map state for new research
      provider.clearCurrentDrawing();
      provider.clearAllPolygons();
      provider.clearMarkers();
      provider.clearSelectedLocationData();
      provider.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Search Location',
                      style: AppTextStyles.titleMedium().copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          Icons.search,
                          color: AppColors.text2.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search for a location',
                            hintStyle: AppTextStyles.regularText().copyWith(
                              color: AppColors.text2.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              ref.read(mapProvider).searchPlaces(value.trim());
                            }
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              ref.read(mapProvider).searchPlaces(value.trim());
                            }
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              const Divider(),
              
              // Search results
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final mapState = ref.watch(mapProvider);
                    
                    if (mapState.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary1,
                        ),
                      );
                    }
                    
                    if (mapState.searchResults.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: AppColors.text2.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for a location',
                              style: AppTextStyles.regularText().copyWith(
                                color: AppColors.text2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: mapState.searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = mapState.searchResults[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary1.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary1,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            result['name'] ?? '',
                            style: AppTextStyles.regularTextBold(),
                          ),
                          subtitle: Text(
                            result['formatted_address'] ?? '',
                            style: AppTextStyles.subTitle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            await ref.read(mapProvider).selectSearchResult(result);
                            _searchController.clear();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => LocationDetailsSheet(
          locationData: data,
          onClose: () {
            Navigator.pop(context);
            ref.read(mapProvider).clearSelectedLocationData();
          },
        ),
      ),
    );
  }

  // Calculate area of polygon in square meters using Shoelace formula
  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0;
    
    double area = 0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }
    area = (area / 2.0).abs();
    
    // Convert to square meters (approximate)
    // 1 degree of latitude ≈ 111,320 meters
    // 1 degree of longitude varies by latitude
    double avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    double metersPerDegreeLat = 111320;
    double metersPerDegreeLng = 111320 * math.cos(avgLat * math.pi / 180);
    
    return area * metersPerDegreeLat * metersPerDegreeLng;
  }

  Future<void> _saveLocationDataToConversation(
    double centerLat,
    double centerLng,
    List<LatLng> polygonPoints,
  ) async {
    try {
      print('💾 Saving location data to conversation: ${widget.conversationId}');
      
      // Calculate area
      double areaInSquareMeters = _calculatePolygonArea(polygonPoints);
      double areaInAcres = areaInSquareMeters / 4046.86; // Convert to acres
      
      // Prepare location data
      final locationData = {
        'center': {
          'latitude': centerLat,
          'longitude': centerLng,
        },
        'polygon_points': polygonPoints.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
        'area': {
          'square_meters': areaInSquareMeters,
          'acres': areaInAcres,
          'hectares': areaInSquareMeters / 10000,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      print('📊 Location data prepared: ${locationData['area']}');
      
      // Update conversation with location data
      final conversationsProvider = ref.read(researchConversationsProvider.notifier);
      await conversationsProvider.updateLocationData(
        widget.conversationId!,
        locationData,
      );
      
      print('✅ Location data saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyzing location...'),
            backgroundColor: AppColors.primary1,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Generate AI analysis
      await _generateAndSaveAIAnalysis(centerLat, centerLng, areaInSquareMeters);
      
    } catch (e) {
      print('❌ Error saving location data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving location data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateAndSaveAIAnalysis(
    double latitude,
    double longitude,
    double area,
  ) async {
    try {
      print('🤖 ============ STARTING AI ANALYSIS ============');
      print('🤖 Location: Lat=$latitude, Lng=$longitude');
      print('🤖 Area: $area square meters');
      print('🤖 Conversation ID: ${widget.conversationId}');
      
      // Get current user ID
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Send user message first
      print('📤 Sending user message...');
      final messagesService = ref.read(researchMessagesProvider.notifier);
      await messagesService.sendTextMessage(
        conversationId: widget.conversationId!,
        researcherId: currentUser.id,
        content: 'Research the best use case and development for the plot of land selected on the map',
      );
      print('✅ User message sent successfully');
    
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AIAnalysisLoadingDialog(),
      );
    }
      
      // Get enriched location data
      final mapService = MapService();
      print('🗺️ Fetching enriched location data from Google Maps...');
      final enrichedData = await mapService.getEnrichedLocationDataForAI(
        latitude: latitude,
        longitude: longitude,
        area: area,
      );
      
      print('📍 Enriched location data retrieved:');
      print('   - Address: ${enrichedData['formatted_address']}');
      print('   - City: ${enrichedData['city']}');
      print('   - Location Type: ${enrichedData['is_city_or_village']}');
      print('   - Roads: ${enrichedData['main_roads']}');
      print('   - Nearby Places: ${(enrichedData['nearby_places'] as List).length} places found');
      
      // Generate AI recommendations
      final fenceAIService = FenceAIService();
      print('🤖 Calling OpenAI API for land development recommendations...');
      final aiResponse = await fenceAIService.generateLandDevelopmentRecommendations(
        latitude: latitude,
        longitude: longitude,
        area: area,
        enrichedLocationData: enrichedData,
      );
      
      print('🎯 ============ AI RECOMMENDATIONS GENERATED ============');
      print('📝 AI Response Length: ${aiResponse.length} characters');
      print('📝 AI Response Preview (first 500 chars):');
      print(aiResponse.substring(0, aiResponse.length > 500 ? 500 : aiResponse.length));
      print('📝 ============================================');
      
      // Prepare location header
      final areaInAcres = area / 4046.86;
      final locationHeader = '''
**Location Analysis**

**📍 Location:** ${enrichedData['formatted_address'] ?? 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}'}

**📏 Land Size:** ${areaInAcres.toStringAsFixed(2)} acres (${(area / 10000).toStringAsFixed(2)} hectares / ${area.toStringAsFixed(0)} sq meters)

---

''';
      
      // Concatenate location details with AI response
      final fullResponse = locationHeader + aiResponse;
      print('📝 Full response with location header prepared');
      
      // Save AI response as a received message using the service directly
      print('💾 Saving AI response to database...');
      print('💾 Conversation ID: ${widget.conversationId}');
      print('💾 Content Type: ${ContentType.text.toJson()}');
      print('💾 Message Type: received');
      
      final savedMessage = await messagesService.receiveMessage(
        conversationId: widget.conversationId!,
        content: fullResponse,
        contentType: ContentType.text,
      );
      
      if (savedMessage != null) {
        print('✅ AI analysis saved to messages successfully!');
        print('✅ Message ID: ${savedMessage.id}');
        print('✅ Created At: ${savedMessage.createdAt}');
        
        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
        
        // Show analysis in bottom sheet
        if (mounted) {
          await _showAnalysisBottomSheet(fullResponse, area);
        }
      } else {
        print('❌ Failed to save message - savedMessage is null');
        throw Exception('Failed to save AI response to database');
      }
      
    } catch (e, stackTrace) {
      print('❌ ============ ERROR IN AI ANALYSIS ============');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ============================================');
      
      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating AI analysis: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showAnalysisBottomSheet(String analysis, double area) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: AppColors.primary1,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: AppTextStyles.titleMedium().copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Area: ${(area / 4046.86).toStringAsFixed(2)} acres',
                            style: AppTextStyles.subTitle(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Analysis content with markdown rendering
              Expanded(
                child: Markdown(
                  controller: scrollController,
                  data: analysis,
                  padding: const EdgeInsets.all(24),
                  styleSheet: MarkdownStyleSheet(
                    h1: AppTextStyles.titleMedium().copyWith(
                      fontSize: 24,
                      color: AppColors.primary1,
                    ),
                    h2: AppTextStyles.titleMedium().copyWith(
                      fontSize: 20,
                      color: AppColors.primary1,
                    ),
                    h3: AppTextStyles.regularTextBold().copyWith(
                      fontSize: 18,
                      color: AppColors.text1,
                    ),
                    p: AppTextStyles.regularText().copyWith(
                      height: 1.6,
                      color: AppColors.text2,
                    ),
                    strong: AppTextStyles.regularTextBold().copyWith(
                      color: AppColors.text1,
                    ),
                    em: AppTextStyles.regularText().copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.text2,
                    ),
                    listBullet: AppTextStyles.regularText().copyWith(
                      color: AppColors.primary1,
                    ),
                    blockSpacing: 12,
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: AppTextStyles.regularTextBold().copyWith(
                            color: AppColors.primary1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to chat page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResearchChat(
                                conversationId: widget.conversationId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Continue Chat',
                          style: AppTextStyles.regularTextBold().copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final screenSize = MediaQuery.of(context).size;

    print('🗺️ MapPage: Building with position ${mapState.currentPosition}');

    // Show location details when data is loaded
    ref.listen(mapProvider, (previous, next) {
      if (next.selectedLocationData != null &&
          previous?.selectedLocationData != next.selectedLocationData) {
        _showLocationDetails(context, next.selectedLocationData!);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: const Drawer(
        width: 320,
        child: SideBar(),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) async {
              print('🗺️ GoogleMap: onMapCreated callback triggered');
              ref.read(mapProvider).onMapCreated(controller);
              // Small delay to ensure map is fully loaded
              await Future.delayed(const Duration(milliseconds: 500));
              print('🗺️ GoogleMap: Map should be visible now');
            },
            initialCameraPosition: CameraPosition(
              target: mapState.currentPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            liteModeEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            polygons: mapState.polygons.union({
              // Current drawing polygon (if in draw mode)
              if (mapState.isDrawMode && mapState.polygonPoints.isNotEmpty)
                Polygon(
                  polygonId: const PolygonId('current_drawing'),
                  points: mapState.polygonPoints,
                  fillColor: AppColors.primary1.withOpacity(0.2),
                  strokeColor: AppColors.primary1,
                  strokeWidth: 2,
                  geodesic: true,
                ),
            }),
            markers: mapState.markers.union({
              // Add markers for polygon points while drawing
              ...mapState.polygonPoints.asMap().entries.map((entry) {
                return Marker(
                  markerId: MarkerId('point_${entry.key}'),
                  position: entry.value,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                );
              }),
            }),
            onTap: (LatLng position) {
              if (mapState.isDrawMode) {
                ref.read(mapProvider).addPolygonPoint(position);
              }
            },
            onCameraMove: (CameraPosition position) {
              ref.read(mapProvider).updateCameraPosition(position);
            },
          ),

          // Top bar with search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header with menu and title
                    Row(
                      children: [
                        // Menu button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.text1),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                        const Spacer(),
                        // Title
                        Text(
                          'Discover on Map',
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        // Chat/messages button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: AppColors.text1),
                            onPressed: () {
                              // Handle chat
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Search and select an area on the map and click the search icon to search and get results',
                        style: AppTextStyles.regularText().copyWith(
                          fontSize: 14,
                          color: AppColors.text2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    InkWell(
                      onTap: () {
                        _showSearchBottomSheet(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppColors.text2.withOpacity(0.5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search location or draw on map',
                                style: AppTextStyles.regularText().copyWith(
                                  color: AppColors.text2.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary1,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Left side controls (zoom and location)
          Positioned(
            left: 16,
            top: screenSize.height * 0.5 - 150,
            child: Column(
              children: [
                // Zoom in
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 28),
                    color: AppColors.text1,
                    onPressed: () {
                      ref.read(mapProvider).zoomIn();
                    },
                  ),
                ),
                // Zoom out
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 28),
                    color: AppColors.text1,
                    onPressed: () {
                      ref.read(mapProvider).zoomOut();
                    },
                  ),
                ),
                // Current location
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, size: 28),
                    color: AppColors.primary1,
                    onPressed: () {
                      ref.read(mapProvider).getCurrentLocation();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom draw control (hide only if location data exists)
          if (mapState.selectedLocationData == null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: mapState.isDrawMode
                        ? AppColors.secondary2
                        : AppColors.primary1,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!mapState.isDrawMode) ...[
                        // Draw button
                        InkWell(
                          onTap: () {
                            ref.read(mapProvider).toggleDrawMode();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Draw to search',
                                style: AppTextStyles.regularTextBold().copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Drawing mode controls
                        InkWell(
                          onTap: () {
                            ref.read(mapProvider).clearCurrentDrawing();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.close,
                                color: AppColors.text1,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Click and drag to draw',
                          style: AppTextStyles.regularText().copyWith(
                            color: AppColors.text1,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (mapState.polygonPoints.length >= 3)
                          InkWell(
                            onTap: () async {
                              // Calculate center of polygon
                              double avgLat = 0;
                              double avgLng = 0;
                              for (var point in mapState.polygonPoints) {
                                avgLat += point.latitude;
                                avgLng += point.longitude;
                              }
                              avgLat /= mapState.polygonPoints.length;
                              avgLng /= mapState.polygonPoints.length;
                              
                              // Search the area
                              await ref.read(mapProvider).searchArea(
                                LatLng(avgLat, avgLng),
                              );
                              
                              // Save location data to conversation
                              if (widget.conversationId != null) {
                                await _saveLocationDataToConversation(
                                  avgLat,
                                  avgLng,
                                  mapState.polygonPoints,
                                );
                              }
                              
                              ref.read(mapProvider).toggleDrawMode();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary1,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (mapState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
