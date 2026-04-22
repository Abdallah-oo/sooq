import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Auth/presentation/cubits/Pick_Image_Cubit/pick_image_cubit.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({super.key, required this.cropForProfile});

  final bool cropForProfile;

  /// Helper ثابت لعرض الـ bottom sheet بطريقة منظمة
  static Future<void> show(
    BuildContext context, {
    required bool cropForProfile,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<PickImageCubit>(),
        child: ImageSourceBottomSheet(cropForProfile: cropForProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            const Gap(8),
            const CustomText(
              style: AppTextStyles.titleMedium,
              text: 'Select Image Source',
            ),
            const Divider(height: 20),
            BlocBuilder<PickImageCubit, PickImageState>(
              builder: (context, state) {
                final hasImage =
                    context.read<PickImageCubit>().imageFile != null;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SourceOption(
                      icon: CupertinoIcons.camera,
                      label: 'Camera',
                      onTap: () => _onSourceSelected(
                        context,
                        source: ImageSource.camera,
                      ),
                    ),
                    _SourceOption(
                      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                      label: 'Gallery',
                      onTap: () => _onSourceSelected(
                        context,
                        source: ImageSource.gallery,
                      ),
                    ),
                    if (hasImage)
                      _SourceOption(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        iconColor: AppColors.errorDark,
                        labelColor: AppColors.error,
                        onTap: () => _onDeleteSelected(context),
                      ),
                  ],
                );
              },
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  void _onSourceSelected(BuildContext context, {required ImageSource source}) {
   context.pop();
    context.read<PickImageCubit>().pickImage(
      source: source,
      cropForProfile: cropForProfile,
    );
  }

  void _onDeleteSelected(BuildContext context) {
    context.pop();
    context.read<PickImageCubit>().deleteImage();
  }
}

// ──────────────────────────────────────────────
// Private Sub-Widgets
// ──────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
