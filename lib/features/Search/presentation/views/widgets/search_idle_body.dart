import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';

class SearchIdleBody extends StatelessWidget {
  const SearchIdleBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Recent Searches ──
          BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (p, c) => p.recentSearches != c.recentSearches,
            builder: (context, state) {
              if (state.recentSearches.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //recent searches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText(text: 'Recent', style: AppTextStyles.titleSmall),
                      TextButton(
                        onPressed: cubit.clearAllRecent,
                        child: CustomText(
                          text: 'Clear all',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.recentSearches.map((query) {
                      return _RecentChip(
                        query: query,
                        onTap: () => cubit.selectSuggestion(query),
                        onRemove: () => cubit.removeRecent(query),
                      );
                    }).toList(),
                  ),
                  const Gap(28),
                  const Divider(color: AppColors.border, height: 1),
                  const Gap(28),
                ],
              );
            },
          ),

          // ── Trending ──
          BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (p, c) => p.trending != c.trending,
            builder: (context, state) {
              if (state.trending.isEmpty) return const SizedBox.shrink();

              return Column(
                children: [
                  const CustomText(text: '🔥  Trending', style: AppTextStyles.titleSmall),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.trending.map((name) {
                      return _TrendingChip(name: name, onTap: () => cubit.selectSuggestion(name));
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.query, required this.onTap, required this.onRemove});

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 15, color: AppColors.secondaryText),
            const Gap(6),
            Text(query, style: AppTextStyles.labelMedium),
            const Gap(6),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  const _TrendingChip({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.trending_up_rounded, size: 15, color: AppColors.primary),
            const Gap(6),
            CustomText(
              text: name,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
