import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';

/// Subtotal / discount / delivery / total card. Shared by checkout and order details.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({
    super.key,
    required this.subtotal,
    required this.discountAmount,
    required this.discountPercent,
    required this.deliveryFee,
    required this.total,
    this.remainingForFreeDelivery = 0,
  });

  final double subtotal;
  final double discountAmount;
  final double discountPercent;
  final double deliveryFee;
  final double total;

  /// When > 0 a "add X more for free delivery" hint is shown.
  final double remainingForFreeDelivery;

  String get _percentLabel => discountPercent % 1 == 0
      ? discountPercent.toInt().toString()
      : discountPercent.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Line(label: 'Subtotal', value: Money.format(subtotal)),
          if (discountAmount > 0) ...[
            const Gap(8),
            _Line(
              label: 'Discount ($_percentLabel%)',
              value: '-${Money.format(discountAmount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Gap(8),
          _Line(
            label: 'Delivery',
            value: deliveryFee == 0 ? 'FREE' : Money.format(deliveryFee),
            valueColor: deliveryFee == 0 ? AppColors.success : null,
          ),
          if (remainingForFreeDelivery > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Add ${Money.format(remainingForFreeDelivery)} more for free delivery',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, thickness: 1, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(text: 'Total', style: AppTextStyles.titleMedium),
              CustomText(
                text: Money.format(total),
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, style: AppTextStyles.bodyMedium),
        CustomText(
          text: value,
          style: AppTextStyles.labelLarge.copyWith(color: valueColor ?? AppColors.primaryText),
        ),
      ],
    );
  }
}
