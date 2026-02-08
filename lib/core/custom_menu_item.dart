class CustomMenuItem {
  CustomMenuItem({
    required this.name,
    required this.description,
    required this.category,
  });

  final String name;
  final String description;
  final String category;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'description': description,
        'category': category,
      };

  static CustomMenuItem fromJson(Map<String, Object?> json) {
    final name = json['name'];
    final description = json['description'];
    final category = json['category'];
    if (name is! String || description is! String) {
      throw FormatException('Invalid CustomMenuItem json: $json');
    }
    return CustomMenuItem(
      name: name,
      description: description,
      category: category is String && category.trim().isNotEmpty
          ? category
          : 'CUSTOM',
    );
  }
}
