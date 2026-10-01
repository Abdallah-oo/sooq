class BannerModel {
  final String id;
  final String? title;
  final String imageUrl;
  final int sortOrder;

  const BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      imageUrl: json['image_url'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
