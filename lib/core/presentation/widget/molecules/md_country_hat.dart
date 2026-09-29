import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';

/// A tiny costume accessory worn by [MdMascotFace] (and, on the live
/// interview screen, layered over the Rive avatar) for the chosen [country]
/// — a lightweight, purely cosmetic way to make the character feel dressed
/// for the destination without touching the `.riv` rig itself (that would
/// need re-authoring the file in the Rive editor, outside what this codebase
/// can generate). Most countries get a friendly party hat in a rotating
/// accent color with a little flag pennant; Japan gets a special hachimaki
/// (the red-sun headband) since it doesn't read as itself in party-hat form.
class MdCountryHat extends StatelessWidget {
  const MdCountryHat({super.key, required this.country, this.size = 96});

  final Country? country;

  /// The size of the face this hat is worn on top of — the hat scales from
  /// this so it always sits proportionally.
  final double size;

  /// Every variant is laid out in a box of this same height, and every
  /// variant's own painted content is bottom-aligned flush with that box's
  /// edge — so no matter which accessory is showing, "the box's bottom" is
  /// always "the accessory's own visual bottom", and a caller positioning
  /// this widget only ever needs one anchor number, not one per variant.
  double get _boxHeight => size * 0.85;

  /// Fixed font size the flag emoji is rasterized at before being scaled
  /// down to its real on-screen size (see the comment where it's used).
  static const _flagRasterFontSize = 64.0;

  @override
  Widget build(BuildContext context) {
    if (country == null) return SizedBox(width: size, height: _boxHeight);

    final Widget accessory;
    if (country!.code == 'JP') {
      accessory = SizedBox(
        width: size,
        height: size * 0.6,
        child: CustomPaint(painter: _HachimakiPainter()),
      );
    } else {
      accessory = SizedBox(
        width: size,
        height: _boxHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size, _boxHeight),
              painter: _PartyHatPainter(_colorFor(country!)),
            ),
            Positioned(
              bottom: size * 0.02,
              // Rendered at a large fixed font size and scaled down rather
              // than sized directly at `size * 0.16` — at that small a size,
              // Windows' color-emoji font rasterizes flag glyphs at a low
              // internal bitmap resolution, so they come out visibly
              // pixelated. Rasterizing large first gives it far more pixels
              // to downsample from, which reads crisp at any hat size.
              child: Transform.scale(
                scale: (size * 0.16) / _flagRasterFontSize,
                child: Text(
                  country!.flagEmoji,
                  style: const TextStyle(fontSize: _flagRasterFontSize),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: size,
      height: _boxHeight,
      child: Align(alignment: Alignment.bottomCenter, child: accessory),
    );
  }

  /// A small rotating palette (not the flag's real colors — this is a party
  /// hat, not a flag replica) so different destinations still look visually
  /// distinct from one another while staying inside the app's own accent set.
  Color _colorFor(Country country) {
    const palette = [
      AppColors.accent,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      Color(0xFFEC4899), // pink-500 — outside the core palette, reserved for
      // this rotating "costume" use only, never for functional UI elsewhere.
    ];
    return palette[country.code.hashCode.abs() % palette.length];
  }
}

class _PartyHatPainter extends CustomPainter {
  _PartyHatPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final conePaint = Paint()..color = color;
    final cone = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.86, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 1.05,
        size.width * 0.14,
        size.height * 0.92,
      )
      ..close();
    canvas.drawPath(cone, conePaint);

    // A couple of lighter stripes for a "party hat", not a plain triangle.
    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (final t in [0.35, 0.62]) {
      final stripe = Path()
        ..moveTo(size.width * 0.5, size.height * t * 0.55)
        ..lineTo(size.width * (0.5 + 0.36 * t), size.height * (0.55 + 0.45 * t))
        ..lineTo(size.width * (0.5 + 0.30 * t), size.height * (0.6 + 0.45 * t))
        ..lineTo(size.width * 0.5, size.height * (t * 0.55 + 0.05))
        ..close();
      canvas.drawPath(stripe, stripePaint);
    }

    canvas.drawCircle(
      Offset(size.width * 0.5, 0),
      size.width * 0.09,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PartyHatPainter oldDelegate) => oldDelegate.color != color;
}

/// The hachimaki: a white headband tied at the back with a red rising-sun
/// circle centered on the front — instantly readable as "Japan" the way a
/// generic party hat with a flag sticker wouldn't be.
class _HachimakiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Drawn flush with this box's own bottom edge (rather than centered
    // mid-box) so it lines up with the other accessory variants, which are
    // all bottom-aligned against the shared slot in [MdCountryHat].
    final bandRect = Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55);
    final bandPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, Radius.circular(size.height * 0.28)),
      bandPaint,
    );

    // Knot ties trailing off one side.
    final tiePaint = Paint()..color = Colors.white;
    final tie = Path()
      ..moveTo(size.width * 0.88, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 1.05,
        size.height * 0.6,
        size.width * 1.08,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 1.0,
        size.height * 0.85,
        size.width * 0.9,
        size.height * 0.95,
      )
      ..close();
    canvas.drawPath(tie, tiePaint);

    // The rising-sun disc, centered on the band.
    final sunCenter = Offset(size.width * 0.5, size.height * 0.725);
    canvas.drawCircle(sunCenter, size.height * 0.22, Paint()..color = const Color(0xFFDC2626));
  }

  @override
  bool shouldRepaint(covariant _HachimakiPainter oldDelegate) => false;
}
