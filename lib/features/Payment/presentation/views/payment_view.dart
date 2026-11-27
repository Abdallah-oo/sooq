import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Payment/presentation/cubit/payment_cubit.dart';
import 'package:sooq/features/Payment/presentation/views/widgets/paymob_web_view.dart';

/// Online payment screen: creates the session, shows Paymob's page, then
/// waits for the server to confirm the payment before reporting success.
class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  /// Home first, so "back" from the order details never lands on a dead screen.
  void _goToOrder(BuildContext context) {
    final orderId = context.read<PaymentCubit>().state.order.id;
    context.go(Routes.root);
    context.push(Routes.orderDetails, extra: orderId);
  }

  Future<void> _onLeave(BuildContext context) async {
    final status = context.read<PaymentCubit>().state.status;

    // Don't interrupt the confirmation step.
    if (status == PaymentFlowStatus.verifying || status == PaymentFlowStatus.paid) return;

    if (status == PaymentFlowStatus.creating || status == PaymentFlowStatus.awaiting) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave payment?'),
          content: const Text(
            'Your order is saved but not paid yet. You can pay later from My Orders.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      if (leave != true || !context.mounted) return;
    }
    _goToOrder(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onLeave(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _onLeave(context),
          ),
          title: const CustomText(text: 'Payment', style: AppTextStyles.titleLarge),
        ),
        body: BlocConsumer<PaymentCubit, PaymentState>(
          listenWhen: (prev, curr) =>
              curr.status == PaymentFlowStatus.paid && prev.status != PaymentFlowStatus.paid,
          listener: (context, state) {
            context.pushReplacement(Routes.orderSuccess, extra: state.order);
          },
          builder: (context, state) {
            final cubit = context.read<PaymentCubit>();

            switch (state.status) {
              case PaymentFlowStatus.creating:
                return const _Loading(message: 'Preparing secure payment…');

              case PaymentFlowStatus.awaiting:
                final session = state.session!;
                return PaymobWebView(
                  checkoutUrl: session.checkoutUrl,
                  returnUrl: session.returnUrl,
                  onReturn: cubit.onPaymentReturn,
                );

              case PaymentFlowStatus.verifying:
                return const _Loading(message: 'Confirming your payment…');

              case PaymentFlowStatus.paid:
                return const _Loading(message: 'Payment received');

              case PaymentFlowStatus.failed:
                return _ResultState(
                  icon: Icons.cancel_outlined,
                  iconColor: AppColors.error,
                  title: 'Payment failed',
                  message:
                      'Your payment was not completed. You can try again or pay later from My Orders.',
                  primaryLabel: 'Try again',
                  onPrimary: cubit.start,
                  secondaryLabel: 'View order',
                  onSecondary: () => _goToOrder(context),
                );

              case PaymentFlowStatus.timeout:
                return _ResultState(
                  icon: Icons.hourglass_top_rounded,
                  iconColor: Colors.orange,
                  title: 'Confirming your payment',
                  message:
                      'We have not received the confirmation yet. Your order will update automatically, check My Orders in a moment.',
                  primaryLabel: 'View order',
                  onPrimary: () => _goToOrder(context),
                );

              case PaymentFlowStatus.error:
                return _ResultState(
                  icon: Icons.error_outline_rounded,
                  iconColor: AppColors.error,
                  title: 'Could not start payment',
                  message: state.errorMessage ?? 'Something went wrong, please try again.',
                  primaryLabel: 'Try again',
                  onPrimary: cubit.start,
                  secondaryLabel: 'Pay later',
                  onSecondary: () => _goToOrder(context),
                );
            }
          },
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const Gap(16),
          CustomText(text: message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ResultState extends StatelessWidget {
  const _ResultState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: iconColor),
            const Gap(16),
            CustomText(text: title, style: AppTextStyles.titleMedium, align: TextAlign.center),
            const Gap(8),
            CustomText(
              text: message,
              maxLines: 4,
              align: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                radius: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: onPrimary,
                child: CustomText(
                  text: primaryLabel,
                  align: TextAlign.center,
                  style: AppTextStyles.button,
                ),
              ),
            ),
            if (secondaryLabel != null) ...[
              const Gap(8),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
