import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/app_date.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/presentation/views/widgets/order_status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = order.itemsCount;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Order #${order.orderNumber}',
                    style: AppTextStyles.titleSmall,
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const Gap(4),
              CustomText(
                text: AppDate.dateTime(order.createdAt),
                style: AppTextStyles.bodySmall,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, thickness: 1, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: order.canPay
                        ? 'Payment pending'
                        : (count == 0 ? order.paymentMethod.label : '$count item${count == 1 ? '' : 's'}'),
                    style: order.canPay
                        ? AppTextStyles.bodyMedium.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTextStyles.bodyMedium,
                  ),
                  CustomText(
                    text: Money.format(order.total),
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
