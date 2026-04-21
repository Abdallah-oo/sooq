import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Cart/presentation/views/widgets/cart_appbar.dart';
import 'package:sooq/features/Cart/presentation/views/widgets/cart_empty_state.dart';
import 'package:sooq/features/Cart/presentation/views/widgets/cart_item_card.dart';
import 'package:sooq/features/Cart/presentation/views/widgets/cart_summary_sheet.dart';

class CartViewBody extends StatelessWidget {
  const CartViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            CartAppBar(itemCount: state.totalCount),
            if (state.items.isEmpty)
              const Expanded(child: CartEmptyState())
            else
              Expanded(
                child: Stack(
                  children: [
                    // ── Scrollable item list ──
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 350),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const Gap(12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return CartItemCard(item: item);
                      },
                    ),

                    // ── Pinned summary sheet ──
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CartSummarySheet(),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
