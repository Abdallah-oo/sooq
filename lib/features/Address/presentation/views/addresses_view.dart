import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/widgets/message_state.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/presentation/cubits/addresses_cubit/addresses_cubit.dart';
import 'package:sooq/features/Address/presentation/route_args/address_route_args.dart';
import 'package:sooq/features/Address/presentation/views/widgets/address_card.dart';

/// My Addresses. With [selectMode] (used by checkout) tapping a card pops
/// the screen returning the chosen [AddressModel].
class AddressesView extends StatelessWidget {
  const AddressesView({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          text: selectMode ? 'Select address' : 'My Addresses',
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: BlocConsumer<AddressesCubit, AddressesState>(
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
              onAction: () => context.read<AddressesCubit>().fetchAddresses(),
            );
          }
          if (state.addresses.isEmpty) {
            return const MessageState(
              icon: Icons.location_off_outlined,
              title: 'No addresses yet',
              message: 'Add a delivery address to get your order delivered to your door.',
            );
          }
          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<AddressesCubit>().fetchAddresses(silent: true),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: state.addresses.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    final address = state.addresses[index];
                    return AddressCard(
                      address: address,
                      onTap: selectMode ? () => context.pop(address) : null,
                      onMenuAction: (action) => _onMenuAction(context, action, address),
                    );
                  },
                ),
              ),
              if (state.isMutating)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Color(0x33FFFFFF),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              radius: 16,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () => _openPicker(context),
              child: const CustomText(
                text: 'Add new address',
                align: TextAlign.center,
                style: AppTextStyles.button,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, {AddressModel? editing}) async {
    final changed = await context.push<bool>(
      Routes.addressPicker,
      extra: AddressPickerArgs(editing: editing),
    );
    if (changed == true && context.mounted) {
      context.read<AddressesCubit>().fetchAddresses(silent: true);
    }
  }

  Future<void> _onMenuAction(
    BuildContext context,
    AddressMenuAction action,
    AddressModel address,
  ) async {
    switch (action) {
      case AddressMenuAction.edit:
        await _openPicker(context, editing: address);
      case AddressMenuAction.setDefault:
        await context.read<AddressesCubit>().setDefault(address.id);
      case AddressMenuAction.delete:
        final confirmed = await _confirmDelete(context, address);
        if (confirmed && context.mounted) {
          await context.read<AddressesCubit>().deleteAddress(address.id);
        }
    }
  }

  Future<bool> _confirmDelete(BuildContext context, AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address'),
        content: Text('Delete "${address.label}" address?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
