import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/favorite_view.dart';
import 'package:sooq/features/Home/presentation/views/home_view.dart';
import 'package:sooq/features/Profile/profile.dart';
import 'package:sooq/features/Search/presentation/views/search_view.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int currentIndex = 0;

  final List<Widget> pages = const [HomeView(), FavoriteView(), SearchView(), ProfileView()];

  final List<_NavItem> items = const [
    _NavItem(Icons.home, Icons.home_outlined, 'Home'),
    _NavItem(Icons.favorite, Icons.favorite_border, 'Fav'),
    _NavItem(Icons.search, Icons.search_outlined, 'Search'),
    _NavItem(Icons.person, Icons.person_outline, 'Profile'),
  ];

  void onTap(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(index: currentIndex, children: pages),
            Positioned(
              bottom: 20,
              left: 14,
              right: 14,
              child: _ModernNavBar(currentIndex: currentIndex, items: items, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final Function(int) onTap;

  const _ModernNavBar({required this.currentIndex, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppColors.shadowMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;

              return index == 1
                  ? BlocBuilder<FavoritesCubit, FavoritesState>(
                      buildWhen: (p, c) => p.count != c.count,
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 4,
                                  width: isSelected ? 30 : 0,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF20B812),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      isSelected ? items[index].activeIcon : items[index].icon,
                                      color: isSelected
                                          ? const Color(0xFF20B812)
                                          : AppColors.grey700,
                                      size: 26,
                                    ),
                                    if (state.count > 0)
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE53935),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${state.count}',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 4,
                              width: isSelected ? 30 : 0,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF20B812),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Icon(
                              isSelected ? items[index].activeIcon : items[index].icon,
                              color: isSelected ? const Color(0xFF20B812) : AppColors.grey700,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _NavItem(this.activeIcon, this.icon, this.label);
}
