import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';

/// A small painted "sticker" version of the app's friendly face — the same
/// round-head/big-eyes/smile motif as the live interview's Rive avatar, but
/// cheap to render anywhere in the UI (setup wizard, empty states) without
/// pulling in the Rive runtime. Exists purely to make the character feel
/// like one consistent mascot across the app rather than "a rig that only
/// shows up during the interview".
///
/// The launcher icon, adaptive-icon foreground, and splash logo
/// (`assets/icon/*.png`) are rasterized directly from this painter's exact
/// shapes/colors, not a separately drawn image — if this painter changes,
/// regenerate those PNGs (paint the same circle/eyes/blush/smile at a large
/// size to an offscreen canvas and export) so the app icon stays in sync.
class MdMascotFace extends StatelessWidget {
  const MdMascotFace({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MascotFacePainter()),
    );
  }
}

class _MascotFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final headPaint = Paint()
      ..shader = LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, headPaint);

    // Big, slightly-oversized eyes read as "cute" (a classic kawaii cue) far
    // more than a realistic, smaller pair would.
    final eyePaint = Paint()..color = Colors.white;
    final eyeSpacing = radius * 0.42;
    final eyeRadius = radius * 0.16;
    final eyeCenterY = center.dy - radius * 0.06;
    for (final dx in [-eyeSpacing, eyeSpacing]) {
      final eyeCenter = Offset(center.dx + dx, eyeCenterY);
      canvas.drawCircle(eyeCenter, eyeRadius, eyePaint);
      canvas.drawCircle(eyeCenter, eyeRadius * 0.55, Paint()..color = AppColors.primaryDark);
      // A tiny highlight dot in each eye is what makes a painted eye look
      // alive instead of a flat dot.
      canvas.drawCircle(
        Offset(eyeCenter.dx + eyeRadius * 0.25, eyeCenter.dy - eyeRadius * 0.3),
        eyeRadius * 0.22,
        Paint()..color = Colors.white,
      );
    }

    // Blush ellipses — the other classic kawaii cue.
    final blushPaint = Paint()..color = const Color(0xFFFB7185).withValues(alpha: 0.55);
    final blushY = center.dy + radius * 0.28;
    final blushSpacing = radius * 0.72;
    for (final dx in [-blushSpacing, blushSpacing]) {
      canvas.save();
      canvas.translate(center.dx + dx, blushY);
      canvas.scale(1.4, 1.0);
      canvas.drawCircle(Offset.zero, radius * 0.13, blushPaint);
      canvas.restore();
    }

    // Smile.
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round;
    final smileRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.12),
      width: radius * 0.62,
      height: radius * 0.5,
    );
    canvas.drawArc(smileRect, 0.25, 2.6, false, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _MascotFacePainter oldDelegate) => false;
}
