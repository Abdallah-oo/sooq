class OrderItemModel {
  const OrderItemModel({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.unit,
    this.imageUrl,
  });

  final String productName;
  final String? unit;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['product_name'] as String,
      unit: json['unit'] as String?,
      imageUrl: json['image_url'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: (json['line_total'] as num).toDouble(),
    );
  }
}
