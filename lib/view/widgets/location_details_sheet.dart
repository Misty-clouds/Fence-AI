import 'package:flutter/material.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';

class LocationDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> locationData;
  final VoidCallback onClose;

  const LocationDetailsSheet({
    super.key,
    required this.locationData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.text2.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Location Details',
                    style: AppTextStyles.titleMedium(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  _buildSection(
                    'Address',
                    locationData['formatted_address'] ?? 'N/A',
                    Icons.location_on,
                  ),

                  // City/State/Country
                  if (locationData['city'] != null ||
                      locationData['state'] != null ||
                      locationData['country'] != null)
                    _buildSection(
                      'Location',
                      [
                        locationData['city'],
                        locationData['state'],
                        locationData['country'],
                      ].where((e) => e != null).join(', '),
                      Icons.place,
                    ),

                  // Coordinates
                  if (locationData['coordinates'] != null)
                    _buildSection(
                      'Coordinates',
                      'Lat: ${locationData['coordinates']['latitude']?.toStringAsFixed(6)}\n'
                      'Lng: ${locationData['coordinates']['longitude']?.toStringAsFixed(6)}',
                      Icons.gps_fixed,
                    ),

                  // Elevation
                  if (locationData['elevation'] != null)
                    _buildSection(
                      'Elevation',
                      '${locationData['elevation'].toStringAsFixed(2)} meters',
                      Icons.terrain,
                    ),

                  // Nearby businesses
                  if (locationData['nearby_businesses'] != null &&
                      (locationData['nearby_businesses'] as List).isNotEmpty)
                    _buildListSection(
                      'Nearby Businesses',
                      locationData['nearby_businesses'] as List,
                      Icons.business,
                    ),

                  // Nearby schools
                  if (locationData['nearby_schools'] != null &&
                      (locationData['nearby_schools'] as List).isNotEmpty)
                    _buildListSection(
                      'Nearby Schools',
                      locationData['nearby_schools'] as List,
                      Icons.school,
                    ),

                  // Nearby hospitals
                  if (locationData['nearby_hospitals'] != null &&
                      (locationData['nearby_hospitals'] as List).isNotEmpty)
                    _buildListSection(
                      'Nearby Hospitals',
                      locationData['nearby_hospitals'] as List,
                      Icons.local_hospital,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary1),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.regularTextBold().copyWith(
                  color: AppColors.text1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.regularText(),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary1),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.regularTextBold().copyWith(
                  color: AppColors.text1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(5).map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary2.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'N/A',
                          style: AppTextStyles.regularTextBold().copyWith(
                            fontSize: 14,
                          ),
                        ),
                        if (item['vicinity'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['vicinity'],
                            style: AppTextStyles.subTitle().copyWith(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (item['rating'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['rating'].toString(),
                                style: AppTextStyles.regularText().copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (items.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${items.length - 5} more',
                style: AppTextStyles.subTitle().copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
