import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';

class FavoritesAppBar extends StatelessWidget {
  const FavoritesAppBar({super.key, required this.count, required this.sort});

  final int count;
  final FavoritesSort sort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          // ── Back button ──
          const Gap(12),

          // ── Title + count ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                text: 'Favorites',
                style: AppTextStyles.titleLarge,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: CustomText(
                  key: ValueKey(count),
                  text: '$count item${count == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Sort button ──
          IconButton(
            onPressed: () => _SortSheet.show(context, sort),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.sort_rounded, color: AppColors.secondaryText),
                if (sort != FavoritesSort.dateAdded)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // ── Clear all ──
          if (count > 0)
            IconButton(
              onPressed: () => _confirmClearAll(context),
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.error,
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear favorites?', style: AppTextStyles.titleMedium),
        content: Text(
          'All $count saved items will be removed.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoritesCubit>().clearAll();
              Navigator.pop(dialogCtx);
            },
            child: Text(
              'Clear all',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sort bottom sheet — lightweight, no separate file needed ──
class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});
  final FavoritesSort current;

  static void show(BuildContext context, FavoritesSort current) {
    final cubit = context.read<FavoritesCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _SortSheet(current: current),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            const CustomText(text: 'Sort by', style: AppTextStyles.titleMedium),
            const Gap(12),
            ...FavoritesSort.values.map((sort) {
              final selected = sort == current;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.grey300,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 13,
                          color: AppColors.white,
                        )
                      : null,
                ),
                title: CustomText(text:      _sortLabel(sort),
                  style: selected
                      ? AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        )
                      : AppTextStyles.labelLarge,) ,
               
                onTap: () {
                  context.read<FavoritesCubit>().changeSort(sort);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _sortLabel(FavoritesSort sort) => switch (sort) {
    FavoritesSort.dateAdded => 'Date added',
    FavoritesSort.nameAZ => 'Name: A → Z',
    FavoritesSort.nameZA => 'Name: Z → A',
    FavoritesSort.priceLow => 'Price: Low → High',
    FavoritesSort.priceHigh => 'Price: High → Low',
    FavoritesSort.rating => 'Top Rated',
  };
}
