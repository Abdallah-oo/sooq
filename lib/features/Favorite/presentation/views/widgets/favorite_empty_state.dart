import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';

class FavoritesEmptyState extends StatefulWidget {
  const FavoritesEmptyState({super.key});

  @override
  State<FavoritesEmptyState> createState() => _FavoritesEmptyStateState();
}

class _FavoritesEmptyStateState extends State<FavoritesEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Decorative background hearts ──
        Positioned.fill(child: CustomPaint(painter: _HeartPatternPainter())),

        // ── Foreground content ──
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing heart
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.1),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFE53935),
                        size: 58,
                      ),
                    ),
                  ),
                ),
                const Gap(32),

                const  CustomText(text:  'No favorites yet',
                  style: AppTextStyles.titleLarge,
                  align: TextAlign.center,)
            ,
                const Gap(12),
                const CustomText(
                  text: 'Tap the ♥ on any product to save\nit here for later.',
                  style: AppTextStyles.bodyMedium,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── CustomPainter: decorative scattered hollow hearts ──
class _HeartPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.08),
      Offset(size.width * 0.05, size.height * 0.45),
      Offset(size.width * 0.92, size.height * 0.38),
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.78, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.06),
      Offset(size.width * 0.5, size.height * 0.92),
    ];

    final sizes = [28.0, 22.0, 18.0, 26.0, 20.0, 24.0, 16.0, 20.0];

    for (int i = 0; i < positions.length; i++) {
      _drawHeart(canvas, paint, positions[i], sizes[i]);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    final s = size / 2;

    path.moveTo(x, y + s * 0.6);
    path.cubicTo(
      x - s * 1.5,
      y - s * 0.2,
      x - s * 1.5,
      y - s * 1.0,
      x,
      y - s * 0.4,
    );
    path.cubicTo(
      x + s * 1.5,
      y - s * 1.0,
      x + s * 1.5,
      y - s * 0.2,
      x,
      y + s * 0.6,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPatternPainter oldDelegate) => false;
}
