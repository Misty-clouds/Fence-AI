class ResearchConversationModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? title;
  final Map<String, dynamic>? locationData;
  final String? researcherId;

  ResearchConversationModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.title,
    this.locationData,
    this.researcherId,
  });

  factory ResearchConversationModel.fromJson(Map<String, dynamic> json) {
    return ResearchConversationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      title: json['title'] as String?,
      locationData: json['location_data'] as Map<String, dynamic>?,
      researcherId: json['researcher_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'location_data': locationData,
      'researcher_id': researcherId,
    };
    
    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    // Only include updated_at if it exists
    if (updatedAt != null) {
      json['updated_at'] = updatedAt!.toIso8601String();
    }
    
    return json;
  }

  ResearchConversationModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    Map<String, dynamic>? locationData,
    String? researcherId,
  }) {
    return ResearchConversationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      locationData: locationData ?? this.locationData,
      researcherId: researcherId ?? this.researcherId,
    );
  }
}
