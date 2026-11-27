import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/app_date.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/widgets/app_network_image.dart';
import 'package:sooq/core/widgets/message_state.dart';
import 'package:sooq/features/Orders/data/models/order_item_model.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/presentation/cubits/order_details_cubit/order_details_cubit.dart';
import 'package:sooq/features/Orders/presentation/views/widgets/order_status_chip.dart';
import 'package:sooq/features/Orders/presentation/views/widgets/price_breakdown.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const CustomText(text: 'Order details', style: AppTextStyles.titleLarge),
      ),
      body: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
        listenWhen: (prev, curr) =>
            curr.actionError != null && prev.actionError != curr.actionError,
        listener: (context, state) => CustomSnackBar.error(context, state.actionError!),
        builder: (context, state) {
          final order = state.order;

          if (state.isLoading && order == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (order == null) {
            return MessageState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.loadError ?? 'Order not found',
              actionLabel: 'Retry',
              onAction: () => context.read<OrderDetailsCubit>().fetchOrder(),
            );
          }
          return _Content(order: order, isCancelling: state.isCancelling);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.order, required this.isCancelling});

  final OrderModel order;
  final bool isCancelling;

  Future<void> _pay(BuildContext context) async {
    await context.push(Routes.payment, extra: order);
    // Back from the payment screen without paying: show the latest status.
    if (context.mounted) context.read<OrderDetailsCubit>().fetchOrder(silent: true);
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order'),
        content: Text('Cancel order #${order.orderNumber}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep order')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel order', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OrderDetailsCubit>().cancelOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Order #${order.orderNumber}',
                    style: AppTextStyles.titleMedium,
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const Gap(4),
              CustomText(
                text: AppDate.dateTime(order.createdAt),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const _SectionTitle('Items'),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++) ...[
                if (i > 0) const Gap(12),
                _ItemRow(item: order.items[i]),
              ],
            ],
          ),
        ),
        const _SectionTitle('Delivery address'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: order.addressLabel, style: AppTextStyles.titleSmall),
              const Gap(4),
              CustomText(
                text: order.addressFull,
                maxLines: 3,
                style: AppTextStyles.bodyMedium,
              ),
              if (order.addressDetails.isNotEmpty) ...[
                const Gap(4),
                CustomText(text: order.addressDetails, style: AppTextStyles.bodySmall),
              ],
              const Gap(8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.secondaryText),
                  const Gap(6),
                  CustomText(text: order.contactPhone, style: AppTextStyles.bodyMedium),
                ],
              ),
              if (order.deliveryNotes != null && order.deliveryNotes!.trim().isNotEmpty) ...[
                const Gap(8),
                CustomText(
                  text: 'Note: ${order.deliveryNotes!.trim()}',
                  maxLines: 3,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const _SectionTitle('Payment'),
        _Card(
          child: Column(
            children: [
              _InfoRow(label: 'Method', value: order.paymentMethod.label),
              const Gap(8),
              _InfoRow(label: 'Status', value: order.paymentStatus.label),
            ],
          ),
        ),
        const _SectionTitle('Summary'),
        PriceBreakdown(
          subtotal: order.subtotal,
          discountAmount: order.discountAmount,
          discountPercent: order.discountPercent,
          deliveryFee: order.deliveryFee,
          total: order.total,
        ),
        if (order.canPay) ...[
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              radius: 16,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: isCancelling ? null : () => _pay(context),
              child: CustomText(
                text: 'Pay now  ·  ${Money.format(order.total)}',
                align: TextAlign.center,
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
        if (order.canCancel) ...[
          Gap(order.canPay ? 12 : 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCancelling ? null : () => _confirmCancel(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isCancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                    )
                  : const Text('Cancel order'),
            ),
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: CustomText(text: title, style: AppTextStyles.titleSmall),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, style: AppTextStyles.bodyMedium),
        CustomText(text: value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: (imageUrl != null && imageUrl.isNotEmpty)
              ? AppNetworkImage(imageUrl, cacheWidth: 120)
              : const Icon(Icons.shopping_basket_outlined, color: AppColors.secondaryText),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: item.productName, style: AppTextStyles.titleSmall),
              const Gap(2),
              CustomText(
                text: '${Money.format(item.unitPrice)} × ${item.quantity}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const Gap(8),
        CustomText(text: Money.format(item.lineTotal), style: AppTextStyles.labelLarge),
      ],
    );
  }
}
