import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';

class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isEmpty = state.items.isEmpty;

        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: isEmpty ? const Offset(0, 1.5) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isEmpty ? 0 : 1,
            child: GestureDetector(
              onTap: () => context.push(Routes.cart, extra: context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadowPrimary,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // reverse: true,
                        child: Row(
                          children: [
                            const Gap(5),
                            ...state.items.map((item) {
                              return Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: Image.asset(
                                  item.product.image,
                                  fit: BoxFit.contain,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.white.withOpacity(0.4),
                    ),
                    const Gap(10),
                    const CustomText(
                      text: 'View Basket',
                      style: AppTextStyles.button,
                    ),
                    const Gap(10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomText(
                        text: '${state.totalCount}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
