import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/presentation/widget/molecules/md_country_hat.dart';
import 'package:voya/core/presentation/widget/molecules/md_mascot_face.dart';

/// The mascot face plus its (optional) country costume, composed as one
/// unit. Used in the setup wizard, where it doubles as a live preview of
/// "who you're about to talk to" that reacts to the country you pick.
class MdMascotAvatar extends StatelessWidget {
  const MdMascotAvatar({super.key, required this.country, this.size = 96});

  final Country? country;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          MdMascotFace(size: size),
          // The face is bottom-aligned in a container 1.5x its own height, so
          // its top edge sits at `size` px up from the container's bottom —
          // the hat needs to be anchored from that same bottom edge (with a
          // small deliberate overlap so it reads as "worn", not "floating")
          // rather than pinned to the container's top, or it floats well
          // above the head instead of sitting on it.
          Positioned(
            bottom: size * 0.78,
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(country?.code),
                child: MdCountryHat(country: country, size: size),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
