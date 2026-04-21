import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';
import 'package:sooq/features/Search/presentation/views/widgets/search_bar_field.dart';
import 'package:sooq/features/Search/presentation/views/widgets/search_empty_state.dart';
import 'package:sooq/features/Search/presentation/views/widgets/search_idle_body.dart';
import 'package:sooq/features/Search/presentation/views/widgets/search_result_body.dart';

class SearchViewBody extends StatelessWidget {
  const SearchViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Search bar always visible at top ──
          const SearchBarField(),

          // ── Body switches between 4 states ──
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: switch (state.status) {
                    SearchStatus.idle => const SearchIdleBody(
                      key: ValueKey('idle'),
                    ),
                    SearchStatus.loading => const _LoadingBody(
                      key: ValueKey('loading'),
                    ),
                    SearchStatus.results => const SearchResultsBody(
                      key: ValueKey('results'),
                    ),
                    SearchStatus.empty => const SearchEmptyState(
                      key: ValueKey('empty'),
                    ),
                    SearchStatus.error => _ErrorBody(
                      key: const ValueKey('error'),
                      message: state.errorMessage ?? 'An error occurred.',
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle shimmer-style loading indicator ──
class _LoadingBody extends StatelessWidget {
  const _LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.4 + (_anim.value * 0.4);
        return Opacity(
          opacity: opacity,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Gap(8),
                      Container(
                        height: 10,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
//...........................................
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 52,
            color: AppColors.grey300,
          ),
          const Gap(16),
          CustomText(text: message,
            style: AppTextStyles.bodyMedium,
            align: TextAlign.center,
          ),
        
        ],
      ),
    );
  }
}
