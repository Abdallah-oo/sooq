import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/widgets/message_state.dart';
import 'package:sooq/features/Orders/presentation/cubits/orders_cubit/orders_cubit.dart';
import 'package:sooq/features/Orders/presentation/views/widgets/order_card.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const CustomText(text: 'My Orders', style: AppTextStyles.titleLarge),
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listenWhen: (prev, curr) =>
            curr.actionError != null && prev.actionError != curr.actionError,
        listener: (context, state) => CustomSnackBar.error(context, state.actionError!),
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.loadError != null) {
            return MessageState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.loadError!,
              actionLabel: 'Retry',
              onAction: () => context.read<OrdersCubit>().fetchOrders(),
            );
          }
          if (state.orders.isEmpty) {
            return const MessageState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'When you place an order it will show up here.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<OrdersCubit>().fetchOrders(silent: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () async {
                    await context.push(Routes.orderDetails, extra: order.id);
                    // The order may have been cancelled / updated meanwhile.
                    if (context.mounted) {
                      context.read<OrdersCubit>().fetchOrders(silent: true);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
