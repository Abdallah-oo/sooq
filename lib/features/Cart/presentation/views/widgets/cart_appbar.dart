import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CartAppBar({super.key, required this.itemCount});

  final int itemCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,size: 20,),
              color: AppColors.primaryText,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomText(
                  text: 'My Basket',
                  style: AppTextStyles.titleLarge,
                ),
                CustomText(
                  text: '$itemCount item${itemCount == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),

            const Spacer(),

            // Clear all button — only shows when cart has items
            if (itemCount > 0)
              TextButton.icon(
                onPressed: () => _confirmClearAll(context),
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: AppColors.error,
                ),
                label: CustomText(
                  text: 'Clear all',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: 
        const Text('Clear basket?', style: AppTextStyles.titleMedium)
       ,
        content:
        const Text(  'All items will be removed from your basket.',
          style: AppTextStyles.bodyMedium,)
        ,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(  'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              context.pop();
            },
            child: Text(
              'Clear',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
