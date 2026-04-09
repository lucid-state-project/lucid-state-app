/// Model untuk category
class Category {
  /// Category ID
  final String id;

  /// Category name (e.g., "Productivity", "Entertainment")
  final String name;

  /// Category type (e.g., "work", "leisure")
  final String? type;

  /// Category image URL
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.type,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['category_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (type != null) 'type': type,
      if (image != null) 'image': image,
    };
  }

  @override
  String toString() => 'Category(id: $id, name: $name, image: $image)';
}

// ============================================================================

/// Request untuk create activity
/// 
/// Endpoint: POST /activities
class CreateActivityRequest {
  /// Activity name
  final String name;

  /// User ID
  final String userId;

  /// Category ID
  final String categoryId;

  CreateActivityRequest({
    required this.name,
    required this.userId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_id': userId,
      'category_id': categoryId,
    };
  }
}

/// Model untuk activity
class Activity {
  /// Activity ID
  final String id;

  /// Activity name
  final String name;

  /// User ID
  final String userId;

  /// Category ID
  final String categoryId;

  /// Timestamp created
  final String? createdAt;

  Activity({
    required this.id,
    required this.name,
    required this.userId,
    required this.categoryId,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? json['activity_id'] ?? '',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  @override
  String toString() => 'Activity(id: $id, name: $name, categoryId: $categoryId)';
}
