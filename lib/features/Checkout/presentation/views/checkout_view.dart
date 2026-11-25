import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/money.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/widgets/message_state.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Checkout/presentation/cubit/checkout_cubit.dart';
import 'package:sooq/features/Checkout/presentation/views/widgets/checkout_address_card.dart';
import 'package:sooq/features/Checkout/presentation/views/widgets/payment_method_tile.dart';
import 'package:sooq/features/Checkout/presentation/views/widgets/promo_code_field.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_quote.dart';
import 'package:sooq/features/Orders/presentation/views/widgets/price_breakdown.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  Future<void> _chooseAddress(BuildContext context) async {
    final selected = await context.push<AddressModel>(Routes.addresses, extra: true);
    if (selected != null && context.mounted) {
      context.read<CheckoutCubit>().selectAddress(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const CustomText(text: 'Checkout', style: AppTextStyles.titleLarge),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listenWhen: (prev, curr) =>
            (curr.placedOrder != null && prev.placedOrder == null) ||
            (curr.placeError != null && prev.placeError != curr.placeError),
        listener: (context, state) {
          final order = state.placedOrder;
          if (order != null) {
            context.read<CartCubit>().clearCart();
            context.pushReplacement(Routes.orderSuccess, extra: order);
            return;
          }
          CustomSnackBar.error(context, state.placeError!);
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final quote = state.quote;
          if (state.loadError != null || quote == null) {
            return MessageState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.loadError ?? 'Could not load your order',
              actionLabel: 'Retry',
              onAction: () => context.read<CheckoutCubit>().init(),
            );
          }

          final cubit = context.read<CheckoutCubit>();

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      const _SectionTitle('Delivery address'),
                      CheckoutAddressCard(
                        address: state.address,
                        onTap: () => _chooseAddress(context),
                      ),
                      const _SectionTitle('Payment method'),
                      for (final method in PaymentMethod.values.where((m) => m.isAvailable))
                        PaymentMethodTile(
                          method: method,
                          selected: method == state.paymentMethod,
                          onTap: () => cubit.selectPaymentMethod(method),
                        ),
                      const _SectionTitle('Promo code'),
                      PromoCodeField(
                        appliedCode: quote.promoCode,
                        isLoading: state.isUpdatingQuote,
                        errorText: state.promoError,
                        onApply: cubit.applyPromo,
                        onRemove: cubit.removePromo,
                      ),
                      const _SectionTitle('Order summary'),
                      PriceBreakdown(
                        subtotal: quote.subtotal,
                        discountAmount: quote.discountAmount,
                        discountPercent: quote.discountPercent,
                        deliveryFee: quote.deliveryFee,
                        total: quote.total,
                        remainingForFreeDelivery: quote.remainingForFreeDelivery,
                      ),
                    ],
                  ),
                ),
              ),
              _PlaceOrderBar(state: state, quote: quote),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({required this.state, required this.quote});

  final CheckoutState state;
  final OrderQuote quote;

  @override
  Widget build(BuildContext context) {
    final hasAddress = state.address != null;
    final canPlace = hasAddress && !state.isPlacing && !state.isUpdatingQuote;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppColors.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasAddress) ...[
              const CustomText(
                text: 'Select a delivery address to continue',
                style: AppTextStyles.bodySmall,
              ),
              const Gap(8),
            ],
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                radius: 16,
                color: canPlace || state.isPlacing ? null : AppColors.grey300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: canPlace ? () => context.read<CheckoutCubit>().placeOrder() : null,
                child: state.isPlacing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : CustomText(
                        text: 'Place order  ·  ${Money.format(quote.total)}',
                        align: TextAlign.center,
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ],
        ),
      ),
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
