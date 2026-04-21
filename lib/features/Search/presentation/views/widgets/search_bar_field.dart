import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';
import 'package:sooq/features/Search/presentation/views/widgets/search_filter_sheet.dart';

class SearchBarField extends StatelessWidget {
  const SearchBarField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Gap(10),

          // ── Text field ──
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: cubit.fieldController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: AppTextStyles.bodyLarge,
                cursorColor: AppColors.primary,
                cursorHeight: 18,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: AppTextStyles.bodyMedium,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.secondaryText,
                    size: 22,
                  ),
                  suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                    buildWhen: (p, c) => (p.query.isEmpty) != (c.query.isEmpty),
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: state.query.isNotEmpty
                            ? GestureDetector(
                                key: const ValueKey('clear'),
                                onTap: cubit.clearQuery,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.secondaryText,
                                  size: 20,
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      );
                    },
                  ),
                ),
                onChanged: cubit.onQueryChanged,
                onSubmitted: cubit.onSubmitted,
              ),
            ),
          ),

          const Gap(10),

          //  Filter button with active badge
          BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (p, c) =>
                p.filter.activeFilterCount != c.filter.activeFilterCount,
            builder: (context, state) {
              final count = state.filter.activeFilterCount;
              return GestureDetector(
                onTap: () => SearchFilterSheet.show(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: count > 0
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        boxShadow: count > 0 ? AppColors.shadowPrimary : null,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: count > 0
                            ? AppColors.white
                            : AppColors.secondaryText,
                        size: 22,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomText(
                              text: '$count',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                              ),
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
