class UserModel {
  final String id;
  final DateTime createdAt;
  final String? name;
  final String? email;
  final String? role;

  UserModel({
    required this.id,
    required this.createdAt,
    this.name,
    this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? email,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
