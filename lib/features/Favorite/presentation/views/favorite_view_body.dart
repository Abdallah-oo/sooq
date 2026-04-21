import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_app_bar.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_empty_state.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_grid.dart';

class FavoriteViewBody extends StatelessWidget {
  const FavoriteViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
        buildWhen: (p, c) =>
            p.status != c.status || p.count != c.count || p.sort != c.sort,
        builder: (context, state) {
         
          if (state.status == FavoritesStatus.loading) {
            return const _LoadingBody();
          }
          return Column(
            children: [
              FavoritesAppBar(count: state.count, sort: state.sort),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: state.favorites.isEmpty
                      ? const FavoritesEmptyState(key: ValueKey('empty'))
                      : const FavoritesGrid(key: ValueKey('grid')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
