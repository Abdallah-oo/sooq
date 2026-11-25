import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';

/// Pinned bottom sheet of the cart. Delivery fee and promo codes are priced
/// by the server on the checkout screen, so this only shows the subtotal.
class CartSummarySheet extends StatelessWidget {
  const CartSummarySheet({super.key});

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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(text: 'Subtotal', style: AppTextStyles.titleMedium),
                  CustomText(
                    text: Money.format(state.totalPrice),
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const Gap(6),
              const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Delivery fee and promo codes are applied at checkout',
                  maxLines: 2,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: () => context.push(Routes.checkout),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 18),
                      Gap(8),
                      CustomText(text: 'Proceed to checkout', style: AppTextStyles.button),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
