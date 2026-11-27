import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key, required this.order});

  final OrderModel order;

  void _continueShopping(BuildContext context) => context.go(Routes.root);

  void _viewOrder(BuildContext context) {
    // Reset to Home first so "back" from the details screen lands on Home, not on the cart.
    context.go(Routes.root);
    context.push(Routes.orderDetails, extra: order.id);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _continueShopping(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
                const Gap(24),
                const CustomText(text: 'Order placed!', style: AppTextStyles.displaySmall),
                const Gap(8),
                CustomText(
                  text: 'Order #${order.orderNumber}',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                ),
                const Gap(12),
                CustomText(
                  text: order.paymentStatus == PaymentStatus.paid
                      ? 'Payment received. We will confirm your order shortly.'
                      : 'We received your order and will confirm it shortly.',
                  maxLines: 2,
                  align: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const Gap(24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _Row(label: 'Total', value: Money.format(order.total)),
                      const Gap(8),
                      _Row(
                        label: 'Payment',
                        value: order.paymentMethod.isOnline
                            ? '${order.paymentMethod.label} · ${order.paymentStatus.label}'
                            : order.paymentMethod.label,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: () => _viewOrder(context),
                    child: const CustomText(
                      text: 'View order',
                      align: TextAlign.center,
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const Gap(8),
                TextButton(
                  onPressed: () => _continueShopping(context),
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, style: AppTextStyles.bodyMedium),
        CustomText(text: value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}
