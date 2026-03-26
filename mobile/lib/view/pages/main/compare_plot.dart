import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/widgets/side_bar.dart';
import 'package:fence_ai/core/services/land_comparison_service.dart';
import 'package:fence_ai/core/services/map_service.dart';

class ComparePlot extends ConsumerStatefulWidget {
  const ComparePlot({super.key});

  @override
  ConsumerState<ComparePlot> createState() => _ComparePlotState();
}

class _ComparePlotState extends ConsumerState<ComparePlot> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _comparisonCriteriaController = TextEditingController();
  
  Map<String, dynamic>? _land1Data;
  Map<String, dynamic>? _land2Data;
  bool _isComparing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _comparisonCriteriaController.dispose();
    super.dispose();
  }

  Future<void> _selectLand(int landNumber) async {
    // Navigate to map selection (we'll create this)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandSelectionMap(
          landNumber: landNumber,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (landNumber == 1) {
          _land1Data = result;
        } else {
          _land2Data = result;
        }
      });
    }
  }

  Future<void> _compareLands() async {
    if (_land1Data == null || _land2Data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both lands to compare'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final criteria = _comparisonCriteriaController.text.trim();
    if (criteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter comparison criteria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isComparing = true;
      _errorMessage = null;
    });

    try {
      final comparisonService = LandComparisonService();
      final result = await comparisonService.compareLands(
        land1: _land1Data!,
        land2: _land2Data!,
        comparisonCriteria: criteria,
      );

      setState(() {
        _isComparing = false;
      });

      // Navigate to comparison results page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultsPage(
              comparisonResult: result,
              land1Data: _land1Data!,
              land2Data: _land2Data!,
              criteria: criteria,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isComparing = false;
        _errorMessage = 'Failed to compare lands: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.text1, size: 28),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Compare Plots',
          style: AppTextStyles.titleSmall(color: AppColors.text1),
        ),
      ),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary1.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary1,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select two lands on the map and specify what you want to compare',
                      style: AppTextStyles.regularText().copyWith(
                        color: AppColors.primary1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Land 1 selection
            _buildLandSelectionCard(
              landNumber: 1,
              landData: _land1Data,
              onTap: () => _selectLand(1),
            ),

            const SizedBox(height: 16),

            // Visual connector
            Center(
              child: Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary1.withOpacity(0.5),
                      AppColors.primary1,
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Land 2 selection
            _buildLandSelectionCard(
              landNumber: 2,
              landData: _land2Data,
              onTap: () => _selectLand(2),
            ),

            const SizedBox(height: 24),

            // Comparison criteria input
            Text(
              'What would you like to compare?',
              style: AppTextStyles.regularTextBold().copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comparisonCriteriaController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'E.g., Agricultural potential, development costs, accessibility, soil quality, etc.',
                hintStyle: AppTextStyles.regularText(
                  color: Colors.grey.shade500,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary1, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Compare button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isComparing ? null : _compareLands,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary1,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isComparing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.compare_arrows, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Compare Lands',
                            style: AppTextStyles.regularTextBold().copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandSelectionCard({
    required int landNumber,
    required Map<String, dynamic>? landData,
    required VoidCallback onTap,
  }) {
    final bool isSelected = landData != null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary1 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary1
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Land $landNumber',
                    style: AppTextStyles.regularTextBold().copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected ? AppColors.primary1 : Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isSelected) ...[
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap to select location on map',
                      style: AppTextStyles.regularText(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary1,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          landData['address'] ?? 'Selected Location',
                          style: AppTextStyles.regularTextBold(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(landData['area'] ?? 0.0).toStringAsFixed(2)} acres',
                          style: AppTextStyles.subTitle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Simple land selection map page
class LandSelectionMap extends StatefulWidget {
  final int landNumber;

  const LandSelectionMap({super.key, required this.landNumber});

  @override
  State<LandSelectionMap> createState() => _LandSelectionMapState();
}

class _LandSelectionMapState extends State<LandSelectionMap> {
  LatLng? _selectedLocation;
  final List<LatLng> _polygonPoints = [];
  bool _isDrawMode = false;
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final mapService = MapService();
      final results = await mapService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = result['latitude'] as double;
    final lng = result['longitude'] as double;
    final position = LatLng(lat, lng);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );

    setState(() {
      _selectedLocation = position;
      _searchResults = [];
      _searchController.clear();
    });

    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Land ${widget.landNumber}'),
        actions: [
          if (_polygonPoints.isNotEmpty)
            TextButton(
              onPressed: () {
                // Calculate area and return data
                final area = _calculateArea(_polygonPoints);
                Navigator.pop(context, {
                  'latitude': _selectedLocation?.latitude ?? 0.0,
                  'longitude': _selectedLocation?.longitude ?? 0.0,
                  'area': area,
                  'polygon_points': _polygonPoints.map((p) => {
                    'latitude': p.latitude,
                    'longitude': p.longitude,
                  }).toList(),
                  'address': 'Lat: ${_selectedLocation?.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation?.longitude.toStringAsFixed(4)}',
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.5244, 3.3792), // Lagos default
              zoom: 12.0,
            ),
            onTap: (position) {
              if (_isDrawMode) {
                setState(() {
                  _polygonPoints.add(position);
                  _selectedLocation = position;
                });
              }
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
            polygons: _polygonPoints.isNotEmpty
                ? {
                    Polygon(
                      polygonId: const PolygonId('selection'),
                      points: _polygonPoints,
                      fillColor: AppColors.primary1.withOpacity(0.3),
                      strokeColor: AppColors.primary1,
                      strokeWidth: 3,
                    ),
                  }
                : {},
          ),
          // Search bar with dropdown
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primary1,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _searchLocation('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      _searchLocation(value);
                      setState(() {}); // Update UI for clear button
                    },
                  ),
                ),
                
                // Search results dropdown
                if (_searchResults.isNotEmpty || _isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 300),
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
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary1,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
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
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  result['name'] ?? '',
                                  style: AppTextStyles.regularTextBold().copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  result['formatted_address'] ?? '',
                                  style: AppTextStyles.subTitle().copyWith(
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _selectSearchResult(result),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isDrawMode = !_isDrawMode;
                  if (!_isDrawMode && _polygonPoints.isNotEmpty) {
                    // Keep the polygon
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDrawMode ? AppColors.secondary2 : AppColors.primary1,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isDrawMode ? 'Finish Drawing' : 'Start Drawing',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }
    area = (area / 2.0).abs();
    
    // Convert to acres (approximate)
    return area * 111320 * 111320 / 4046.86;
  }
}

// Comparison Results Page - displays results in message page style
class ComparisonResultsPage extends StatelessWidget {
  final String comparisonResult;
  final Map<String, dynamic> land1Data;
  final Map<String, dynamic> land2Data;
  final String criteria;

  const ComparisonResultsPage({
    super.key,
    required this.comparisonResult,
    required this.land1Data,
    required this.land2Data,
    required this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comparison Results',
          style: AppTextStyles.titleSmall(color: AppColors.text1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comparison header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.compare_arrows,
                          color: AppColors.primary1,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Land Comparison',
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Criteria
                  Text(
                    'Comparison Criteria:',
                    style: AppTextStyles.regularTextBold().copyWith(
                      fontSize: 14,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    criteria,
                    style: AppTextStyles.regularText().copyWith(
                      fontSize: 15,
                      color: AppColors.text1,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Land summaries
                  Row(
                    children: [
                      Expanded(
                        child: _buildLandSummary(
                          landNumber: 1,
                          data: land1Data,
                          color: AppColors.primary1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLandSummary(
                          landNumber: 2,
                          data: land2Data,
                          color: AppColors.secondary2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI Response in message style
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary1.withOpacity(0.1),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: AppColors.primary1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fense AI Analysis',
                        style: AppTextStyles.regularTextBold().copyWith(
                          fontSize: 14,
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: comparisonResult,
                    styleSheet: MarkdownStyleSheet(
                      h1: AppTextStyles.titleMedium().copyWith(
                        fontSize: 22,
                        color: AppColors.primary1,
                      ),
                      h2: AppTextStyles.titleMedium().copyWith(
                        fontSize: 19,
                        color: AppColors.primary1,
                      ),
                      h3: AppTextStyles.regularTextBold().copyWith(
                        fontSize: 17,
                        color: AppColors.text1,
                      ),
                      p: AppTextStyles.regularText().copyWith(
                        height: 1.6,
                        fontSize: 15,
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
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLandSummary({
    required int landNumber,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Land $landNumber',
            style: AppTextStyles.regularTextBold().copyWith(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(data['area'] ?? 0.0).toStringAsFixed(2)} acres',
            style: AppTextStyles.regularTextBold().copyWith(
              fontSize: 16,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['address'] ?? 'Location',
            style: AppTextStyles.regularText().copyWith(
              fontSize: 11,
              color: AppColors.text2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
