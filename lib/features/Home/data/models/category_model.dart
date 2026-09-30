class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
