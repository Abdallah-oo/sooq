import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.address});

  final String address;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: CustomText(text: address, style: AppTextStyles.bodyLarge),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: 12),

          // Cart icon with badge
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () => context.push(Routes.cart, extra: context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primaryText,
                      size: 28,
                    ),
                    if (state.totalCount > 0)
                      Positioned(
                        top: -6,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: CustomText(
                            text: '${state.totalCount}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
