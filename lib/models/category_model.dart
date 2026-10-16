class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'wallet',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
