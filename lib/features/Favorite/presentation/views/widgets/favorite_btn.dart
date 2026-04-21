import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.product,
    this.size = 36.0,
    this.backgroundColor,
    this.iconSize, required this.cubit,
  });
  final FavoritesCubit cubit;
  final Product product;
  final double size;
  final Color? backgroundColor;
  final double? iconSize;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<Color?> _color;


  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_ctrl);

    _color = ColorTween(
      begin: Colors.transparent,
      end: const Color(0xFFE53935),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap(bool isFav) async {
    HapticFeedback.mediumImpact();
    if (isFav) {
      // Unfavorite: reverse the animation
      await _ctrl.reverse();
    } else {
      // Favorite: play the spring animation
      _ctrl.forward(from: 0);
    }
    widget.cubit.toggleFavorite(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      bloc: widget.cubit,
      buildWhen: (prev, curr) =>
          prev.isFavorite(widget.product) != curr.isFavorite(widget.product),
      builder: (context, state) {
        final isFav = state.isFavorite(widget.product);

        // Sync animation controller to current state without animating
        if (isFav && _ctrl.value == 0) {
          _ctrl.value = 1.0;
        } else if (!isFav && _ctrl.value == 1) {
          _ctrl.value = 0.0;
        }

        return GestureDetector(
          onTap: () => _onTap(isFav),
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: widget.iconSize ?? widget.size * 0.5,
                    color: isFav
                        ? _color.value ?? const Color(0xFFE53935)
                        : AppColors.grey300,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
