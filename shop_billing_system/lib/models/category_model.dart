class Category {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'category',
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Category.fromMap(String key, Map<dynamic, dynamic> map) {
    return Category(
      id: key,
      name: map['name']?.toString() ?? 'Unnamed Category',
      description: map['description']?.toString() ?? '',
      iconName: map['iconName']?.toString() ?? 'category',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
