import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  Color get _color => switch (status) {
    OrderStatus.pending => Colors.orange,
    OrderStatus.confirmed => Colors.blue,
    OrderStatus.preparing => Colors.purple,
    OrderStatus.outForDelivery => Colors.teal,
    OrderStatus.delivered => AppColors.success,
    OrderStatus.cancelled => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(color: _color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
