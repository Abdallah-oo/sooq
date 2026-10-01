import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(this.url, {super.key, this.fit = BoxFit.contain, this.cacheWidth});
  final String url;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: cacheWidth, // بيفك الصورة بحجم صغير في الرام
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => const CupertinoActivityIndicator(color: AppColors.primary, radius: 8),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.image_not_supported_outlined, color: AppColors.secondaryText),
    );
  }
}
