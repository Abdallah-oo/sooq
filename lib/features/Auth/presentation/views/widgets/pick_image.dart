import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Auth/presentation/cubits/Pick_Image_Cubit/pick_image_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/image_source_bottom_sheet.dart';

const _kAvatarRadius = 45.0;
const _kFallbackAvatarUrl =
    'https://previews.123rf.com/images/tuktukdesign/tuktukdesign1606/tuktukdesign160600119/59070200-user-icon-man-profile-businessman-avatar-person-icon-in-vector-illustration.avif';

class PickImageWidget extends StatelessWidget {
  const PickImageWidget({
    super.key,
    this.defaultImageUrl,
    this.isProfile = false,
    this.isEditing = true,
  });

  final String? defaultImageUrl;
  final bool isProfile;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _AvatarContainer(
          radius: _kAvatarRadius,
          child: BlocBuilder<PickImageCubit, PickImageState>(
            builder: (context, state) => _buildAvatarContent(context, state),
          ),
        ),
        if (isEditing)
          Positioned(
            right: -10,
            bottom: -10,
            child: _CameraButton(
              onTap: () => ImageSourceBottomSheet.show(
                context,
                cropForProfile: isProfile,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent(BuildContext context, PickImageState state) {
    final imageFile = context.read<PickImageCubit>().imageFile;

    if (imageFile != null) {
      return _LocalImage(file: imageFile, radius: _kAvatarRadius);
    }

    return _NetworkImage(imageUrl: defaultImageUrl ?? _kFallbackAvatarUrl);
  }
}

// ──────────────────────────────────────────────
// Private Sub-Widgets
// ──────────────────────────────────────────────

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          clipBehavior: Clip.hardEdge,

          child: child,
        ),
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: AppColors.shadowSm,
          ),
        ),
      ],
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: CupertinoActivityIndicator(color: Colors.white54, radius: 9),
      ),
      errorWidget: (_, __, ___) => const Icon(
        Icons.person_sharp,
        color: AppColors.grey500,
        size: 42,
      ),
    );
  }
}

class _LocalImage extends StatelessWidget {
  const _LocalImage({required this.file, required this.radius});

  final dynamic file; // File
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: radius * 2,
      height: radius * 2,
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
