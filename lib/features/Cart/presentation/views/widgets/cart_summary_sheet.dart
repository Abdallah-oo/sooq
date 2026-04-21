import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Cart/presentation/views/widgets/promo_code_field.dart';

class CartSummarySheet extends StatefulWidget {
  const CartSummarySheet({super.key});

  @override
  State<CartSummarySheet> createState() => _CartSummarySheetState();
}

class _CartSummarySheetState extends State<CartSummarySheet> {
  final ValueNotifier<double> _discount = ValueNotifier(0.0);

  static const double _freeDeliveryThreshold = 50.0;
  static const double _deliveryFee = 2.99;

  @override
  void dispose() {
    _discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppColors.shadowLg,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return ValueListenableBuilder<double>(
            valueListenable: _discount,
            builder: (_, discountRate, __) {
              final subtotal = state.totalPrice;
              final discountAmount = subtotal * discountRate;
              final afterDiscount = subtotal - discountAmount;
              final delivery = afterDiscount >= _freeDeliveryThreshold
                  ? 0.0
                  : _deliveryFee;
              final total = afterDiscount + delivery;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    // ── Drag handle ──
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                
                    // ── Promo code ──
                    PromoCodeField(onApplied: (d) => _discount.value = d),
                    const Gap(20),
                
                    // ── Price breakdown ──
                    _PriceLine(
                      label: 'Subtotal',
                      value: '\$${subtotal.toStringAsFixed(2)}',
                    ),
                    const Gap(8),
                
                    // Discount row — animates in/out
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: discountRate > 0
                          ? Column(
                              children: [
                                _PriceLine(
                                  label:
                                      'Discount (${(discountRate * 100).toInt()}%)',
                                  value:
                                      '-\$${discountAmount.toStringAsFixed(2)}',
                                  valueColor: AppColors.success,
                                ),
                                const SizedBox(height: 8),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                
                    _PriceLine(
                      label: 'Delivery',
                      value: delivery == 0
                          ? 'FREE'
                          : '\$${delivery.toStringAsFixed(2)}',
                      valueColor: delivery == 0 ? AppColors.success : null,
                    ),
                
                    // Free delivery hint
                    if (delivery > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Add \$${(_freeDeliveryThreshold - afterDiscount).toStringAsFixed(2)} more for free delivery',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.border, thickness: 1),
                    ),
                
                    // ── Total ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Total',
                          style: AppTextStyles.titleMedium,
                        ),
                        CustomText(
                          text: '\$${total.toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                
                    // ── Checkout button ──
                    CustomButton(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => _onCheckout(context, total),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.paypal_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const Gap(8),
                          CustomText(
                            text: 'Checkout  ·  \$${total.toStringAsFixed(2)}',
                            style: AppTextStyles.button,
                          ),
                
                       
                        ],
                      ),
                    ),
          
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onCheckout(BuildContext context, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _OrderSuccessDialog(
        total: total,
        onDone: () {
          context.read<CartCubit>().clearCart();
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // go back to home
        },
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value, this.valueColor});

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
          style: AppTextStyles.labelLarge.copyWith(
            color: valueColor ?? AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _OrderSuccessDialog extends StatefulWidget {
  const _OrderSuccessDialog({required this.total, required this.onDone});

  final double total;
  final VoidCallback onDone;

  @override
  State<_OrderSuccessDialog> createState() => __OrderSuccessDialogState();
}

class __OrderSuccessDialogState extends State<_OrderSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Success icon ──
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 52,
                      ),
                    ),
                    const Gap(24),
                    const CustomText(
                      text: 'Order Placed!',
                      style: AppTextStyles.displaySmall,
                    ),

                    const Gap(10),
                    const CustomText(
                      text: 'Your order has been placed\nsuccessfully.',
                      style: AppTextStyles.bodyMedium,
                      align: TextAlign.center,
                    ),
                    const Gap(8),
                    CustomText(
                      text: 'Total paid: \$${widget.total.toStringAsFixed(2)}',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(28),

                    CustomButton(
                      radius: 14,
                      onPressed: widget.onDone,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'Done', style: AppTextStyles.button),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -15,
                  right: -10,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.clear,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
