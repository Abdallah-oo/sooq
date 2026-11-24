import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/config/map_config.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/features/Address/data/services/map_failure.dart';
import 'package:sooq/features/Address/presentation/cubits/address_picker_cubit/address_picker_cubit.dart';
import 'package:sooq/features/Address/presentation/route_args/address_route_args.dart';

/// Uber-style picker: the pin stays in the center, the user moves the map.
/// Pops `true` when the address was saved by the details form.
class AddressPickerView extends StatefulWidget {
  const AddressPickerView({super.key, required this.args});

  final AddressPickerArgs args;

  @override
  State<AddressPickerView> createState() => _AddressPickerViewState();
}

class _AddressPickerViewState extends State<AddressPickerView> {
  final MapController _mapController = MapController();

  AddressPickerCubit get _cubit => context.read<AddressPickerCubit>();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapReady() {
    if (widget.args.editing != null) {
      _cubit.onCameraMoved(_cubit.state.center);
    } else {
      _locateMe(silent: true);
    }
  }

  Future<void> _locateMe({bool silent = false}) async {
    final cubit = _cubit;
    final result = await cubit.locateMe();
    if (!mounted) return;

    result.fold<void>(
      (failure) {
        if (silent) {
          // Stay on the default center, but still resolve its address.
          cubit.onCameraMoved(cubit.state.center);
        } else {
          _handleLocationFailure(failure);
        }
      },
      (point) => _mapController.move(point, MapConfig.locatedZoom),
    );
  }

  Future<void> _handleLocationFailure(MapFailure failure) async {
    switch (failure.type) {
      case MapFailureType.locationServiceDisabled:
        await _showSettingsDialog(
          title: 'Turn on location',
          message: 'Please enable location services to find your position.',
          onOpen: _cubit.openLocationSettings,
        );
      case MapFailureType.permissionPermanentlyDenied:
        await _showSettingsDialog(
          title: 'Location permission needed',
          message: 'Allow location access from the app settings to use your current position.',
          onOpen: _cubit.openAppSettings,
        );
      case MapFailureType.permissionDenied:
      case MapFailureType.network:
      case MapFailureType.unknown:
        if (mounted) CustomSnackBar.warning(context, failure.message);
    }
  }

  Future<void> _showSettingsDialog({
    required String title,
    required String message,
    required Future<void> Function() onOpen,
  }) async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open settings')),
        ],
      ),
    );
    if (open == true) await onOpen();
  }

  Future<void> _confirm(AddressPickerState state) async {
    final saved = await context.push<bool>(
      Routes.addressForm,
      extra: AddressFormArgs(
        location: state.center,
        resolvedAddress: state.address ?? '',
        editing: widget.args.editing,
      ),
    );
    if (saved == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _cubit.state.center,
                    initialZoom: MapConfig.defaultZoom,
                    minZoom: MapConfig.minZoom,
                    maxZoom: MapConfig.maxZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: _onMapReady,
                    onPositionChanged: (camera, _) => _cubit.onCameraMoved(camera.center),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.tileUrlTemplate,
                      userAgentPackageName: MapConfig.userAgentPackageName,
                    ),
                    const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
                  ],
                ),
                // Fixed pin: its tip sits exactly on the map center.
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.location_on, size: 48, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  top: topInset + 12,
                  left: 16,
                  child: _MapButton(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 36,
                  child: BlocSelector<AddressPickerCubit, AddressPickerState, bool>(
                    selector: (state) => state.isLocating,
                    builder: (context, isLocating) => _MapButton(
                      onTap: isLocating ? null : () => _locateMe(),
                      child: isLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _LocationPanel(onConfirm: _confirm),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({required this.onConfirm});

  final void Function(AddressPickerState state) onConfirm;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressPickerCubit, AddressPickerState>(
      builder: (context, state) {
        final canConfirm = !state.isResolving && !state.isLocating;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppColors.shadowLg,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(text: 'Delivery location', style: AppTextStyles.bodySmall),
                const Gap(8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    const Gap(8),
                    Expanded(child: _AddressText(state: state)),
                  ],
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    radius: 16,
                    color: canConfirm ? null : AppColors.grey300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: canConfirm ? () => onConfirm(state) : null,
                    child: const CustomText(
                      text: 'Confirm location',
                      align: TextAlign.center,
                      style: AppTextStyles.button,
                    ),
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

class _AddressText extends StatelessWidget {
  const _AddressText({required this.state});

  final AddressPickerState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLocating) {
      return const CustomText(text: 'Getting your location…', style: AppTextStyles.bodyMedium);
    }
    if (state.isResolving) {
      return const CustomText(text: 'Finding address…', style: AppTextStyles.bodyMedium);
    }
    if (state.resolveFailed) {
      return Row(
        children: [
          const Expanded(
            child: CustomText(
              text: 'Could not load the address. You can type it on the next step.',
              maxLines: 2,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => context.read<AddressPickerCubit>().retry(),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    return CustomText(
      text: state.address ?? 'Move the map to choose a location',
      maxLines: 2,
      style: AppTextStyles.titleSmall,
    );
  }
}
