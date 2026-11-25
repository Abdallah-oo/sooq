import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.deliveryFee,
    required this.total,
    required this.contactPhone,
    required this.addressLabel,
    required this.addressFull,
    required this.createdAt,
    this.promoCode,
    this.addressBuilding,
    this.addressFloor,
    this.addressApartment,
    this.deliveryNotes,
    this.items = const [],
  });

  final String id;
  final int orderNumber;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;

  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final String? promoCode;
  final double deliveryFee;
  final double total;

  final String contactPhone;
  final String addressLabel;
  final String addressFull;
  final String? addressBuilding;
  final String? addressFloor;
  final String? addressApartment;
  final String? deliveryNotes;

  final DateTime createdAt;

  /// Empty when the order came from `place_order` (no join) or a list query
  /// that did not select `order_items`.
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'];

    return OrderModel(
      id: json['id'] as String,
      orderNumber: (json['order_number'] as num).toInt(),
      status: OrderStatus.fromDb(json['status'] as String?),
      paymentMethod: PaymentMethod.fromDb(json['payment_method'] as String?),
      paymentStatus: PaymentStatus.fromDb(json['payment_status'] as String?),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountPercent: (json['discount_percent'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      promoCode: json['promo_code'] as String?,
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      contactPhone: json['contact_phone'] as String,
      addressLabel: json['address_label'] as String,
      addressFull: json['address_full'] as String,
      addressBuilding: json['address_building'] as String?,
      addressFloor: json['address_floor'] as String?,
      addressApartment: json['address_apartment'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: rawItems is List
          ? rawItems
                .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
          : const [],
    );
  }

  /// Customers can cancel only while the order is pending and unpaid.
  bool get canCancel =>
      status == OrderStatus.pending && paymentStatus == PaymentStatus.unpaid;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// "Building 12 · Floor 3 · Apt 5" (only the parts that exist).
  String get addressDetails {
    final parts = <String>[
      if (_hasText(addressBuilding)) 'Building ${addressBuilding!.trim()}',
      if (_hasText(addressFloor)) 'Floor ${addressFloor!.trim()}',
      if (_hasText(addressApartment)) 'Apt ${addressApartment!.trim()}',
    ];
    return parts.join(' · ');
  }

  static bool _hasText(String? v) => v != null && v.trim().isNotEmpty;
}
