import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Google "G" mark for "Continue with Google" buttons — the one place
/// this app uses an SVG asset instead of drawing natively or using a
/// Material glyph, since Google's own sign-in branding guidelines expect
/// their exact mark, not an app's own icon style.
class MdGoogleLogo extends StatelessWidget {
  const MdGoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/icons/google_logo.svg', width: size, height: size);
  }
}
