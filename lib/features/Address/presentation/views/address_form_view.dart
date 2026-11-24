import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/utils/validators.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/presentation/cubits/address_form_cubit/address_form_cubit.dart';
import 'package:sooq/features/Address/presentation/route_args/address_route_args.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/custom_text_field.dart';

/// Last step: address text (editable), label, building details, phone.
/// Pops `true` once the address is saved.
class AddressFormView extends StatefulWidget {
  const AddressFormView({super.key, required this.args});

  final AddressFormArgs args;

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  static const List<String> _labels = ['Home', 'Work', 'Other'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _floorCtrl;
  late final TextEditingController _apartmentCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;

  late String _label;
  late bool _isDefault;

  AddressModel? get _editing => widget.args.editing;

  /// The only default address can't be un-defaulted (another one must be chosen).
  bool get _isDefaultLocked => _editing?.isDefault == true;

  @override
  void initState() {
    super.initState();
    final editing = _editing;

    _addressCtrl = TextEditingController(text: _initialAddress());
    _buildingCtrl = TextEditingController(text: editing?.building);
    _floorCtrl = TextEditingController(text: editing?.floor);
    _apartmentCtrl = TextEditingController(text: editing?.apartment);
    _phoneCtrl = TextEditingController(text: editing?.phone);
    _notesCtrl = TextEditingController(text: editing?.notes);

    _label = editing == null
        ? _labels.first
        : (_labels.contains(editing.label) ? editing.label : 'Other');
    _isDefault = _isDefaultLocked;
  }

  /// Editing + pin not moved -> keep the saved text; otherwise use the new geocode.
  String _initialAddress() {
    final editing = _editing;
    final resolved = widget.args.resolvedAddress;
    if (editing == null) return resolved;

    final moved =
        (editing.latitude - widget.args.location.latitude).abs() > 1e-5 ||
        (editing.longitude - widget.args.location.longitude).abs() > 1e-5;
    return (moved && resolved.isNotEmpty) ? resolved : editing.fullAddress;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    _apartmentCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Required field';
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone)) return 'Enter a valid phone number';
    return null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = AddressModel(
      id: _editing?.id ?? '',
      label: _label,
      fullAddress: _addressCtrl.text,
      latitude: widget.args.location.latitude,
      longitude: widget.args.location.longitude,
      building: _buildingCtrl.text,
      floor: _floorCtrl.text,
      apartment: _apartmentCtrl.text,
      phone: _phoneCtrl.text,
      notes: _notesCtrl.text,
      isDefault: _isDefault,
    );
    context.read<AddressFormCubit>().save(address, isEdit: _editing != null);
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
        title: CustomText(
          text: _editing == null ? 'Address details' : 'Edit address',
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: BlocListener<AddressFormCubit, AddressFormState>(
        listener: (context, state) {
          if (state.status == AddressFormStatus.failure) {
            CustomSnackBar.error(context, state.errorMessage ?? 'Could not save the address');
          }
          if (state.status == AddressFormStatus.success) {
            CustomSnackBar.success(context, 'Address saved');
            context.pop(true);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _Field(
                  label: 'Address',
                  child: CustomTextField(
                    hint: 'Street, area, city',
                    controller: _addressCtrl,
                    validation: Validators.required,
                    minLines: 2,
                    maxLines: 3,
                  ),
                ),
                _Field(
                  label: 'Save as',
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final label in _labels)
                        ChoiceChip(
                          label: Text(label),
                          avatar: Icon(
                            _iconFor(label),
                            size: 18,
                            color: _label == label ? AppColors.white : AppColors.grey500,
                          ),
                          selected: _label == label,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: _label == label ? AppColors.white : AppColors.primaryText,
                          ),
                          onSelected: (_) => setState(() => _label = label),
                        ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Building',
                        child: CustomTextField(hint: 'No.', controller: _buildingCtrl),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _Field(
                        label: 'Floor',
                        child: CustomTextField(hint: 'No.', controller: _floorCtrl),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _Field(
                        label: 'Apartment',
                        child: CustomTextField(hint: 'No.', controller: _apartmentCtrl),
                      ),
                    ),
                  ],
                ),
                _Field(
                  label: 'Phone number',
                  child: CustomTextField(
                    hint: '01XXXXXXXXX',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validation: _validatePhone,
                  ),
                ),
                _Field(
                  label: 'Delivery notes (optional)',
                  child: CustomTextField(
                    hint: 'Landmark, gate code, ...',
                    controller: _notesCtrl,
                    minLines: 2,
                    maxLines: 3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: CustomText(
                          text: 'Set as default address',
                          style: AppTextStyles.labelMedium,
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        onChanged: _isDefaultLocked ? null : (v) => setState(() => _isDefault = v),
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.white
                              : AppColors.grey500,
                        ),
                        trackColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.primary
                              : AppColors.grey100,
                        ),
                        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                BlocBuilder<AddressFormCubit, AddressFormState>(
                  builder: (context, state) {
                    final isSaving = state.status == AddressFormStatus.saving;
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        radius: 16,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: isSaving ? null : _save,
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const CustomText(
                                text: 'Save address',
                                align: TextAlign.center,
                                style: AppTextStyles.button,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String label) => switch (label) {
    'Home' => Icons.home_rounded,
    'Work' => Icons.work_rounded,
    _ => Icons.location_on_rounded,
  };
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: CustomText(text: label, style: AppTextStyles.labelMedium),
          ),
          child,
        ],
      ),
    );
  }
}
