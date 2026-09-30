import 'package:hive_ce/hive.dart';
import 'package:sooq/core/services/hive/hive_types_ids.dart';
part 'product_model.g.dart';

@HiveType(typeId: HiveTypeIds.products)
class ProductModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final double rating;
  @HiveField(5)
  final int votes;
  @HiveField(6)
  final String categoryId;
  @HiveField(7)
  final String unit;
  @HiveField(8)
  final String categoryName;

  const ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.votes,
    required this.categoryId,
    this.unit = 'piece',
    this.categoryName = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      votes: json['votes'] as int,
      categoryId: json['category_id'] as String,
      // جاي من الـ join (categories.name) أو من الكاش المحلي (category_name)
      categoryName:
          (json['categories'] is Map ? (json['categories'] as Map)['name'] : json['category_name'])
              as String? ??
          '',
      unit: json['unit'] as String? ?? 'piece',
    );
  }
    Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'price': price,
    'rating': rating,
    'votes': votes,
    'category_id': categoryId,
    'category_name': categoryName,
    'unit': unit,
  };

  @override
  bool operator ==(Object other) => other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
