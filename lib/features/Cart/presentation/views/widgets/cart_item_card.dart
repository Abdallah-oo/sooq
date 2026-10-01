import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/widgets/app_network_image.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_btn.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final subtotal = item.product.price * item.quantity;

    return Dismissible(
      key: ValueKey(item.product.name),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<CartCubit>().removeAllOf(item.product),
      background: _DismissBackground(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Product image ──
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppNetworkImage(item.product.imageUrl, cacheWidth: 300),
              ),
              const Gap(14),

              // ── Info column ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: item.product.name, style: AppTextStyles.labelLarge),
                    const Gap(4),
                    CustomText(
                      text: '\$${item.product.price.toStringAsFixed(2)} each',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Gap(10),

                    // ── Quantity controls + subtotal ──
                    Row(
                      children: [
                        _QuantityControl(item: item),
                        const Spacer(),
                        CustomText(
                          text: '\$${subtotal.toStringAsFixed(2)}',
                          style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              FavoriteButton(
                cubit: context.read<FavoritesCubit>(),
                product: item.product,
                size: 28,
                backgroundColor: AppColors.surface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//cart item card sup widgets -----------------------------------------------

// ── Swipe-to-delete background ──
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 26),
          const Gap(4),
          CustomText(
            text: 'Remove',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

// ── Quantity stepper ──
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus / delete
          _StepButton(
            icon: item.quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
            iconColor: item.quantity > 1 ? AppColors.primaryText : AppColors.error,
            onTap: () => context.read<CartCubit>().removeItem(item.product),
          ),

          // Count
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: SizedBox(
              key: ValueKey(item.quantity),
              width: 32,
              child: CustomText(
                text: '${item.quantity}',
                align: TextAlign.center,
                style: AppTextStyles.titleSmall,
              ),
            ),
          ),

          // Plus
          _StepButton(
            icon: Icons.add_rounded,
            iconColor: AppColors.primary,
            onTap: () => context.read<CartCubit>().addItem(item.product),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.iconColor, required this.onTap});

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
