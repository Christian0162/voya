import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

class MdCountrySelector extends StatelessWidget {
  const MdCountrySelector({super.key, required this.selected, required this.onSelected});

  final Country? selected;
  final ValueChanged<Country> onSelected;

  @override
  Widget build(BuildContext context) {
    // Stacking the flag above the name (rather than side by side) gives
    // names like "South Korea" the card's full width to wrap into instead of
    // squeezing them onto one line next to a 26px emoji until they ellipsis.
    // "United States"/"United Kingdom" use [Country.shortName] ("US"/"UK")
    // instead of wrapping at all — two lines of a country's full name reads
    // worse here than just abbreviating the ones long enough to need it.
    //
    // A fixed `mainAxisExtent` (rather than `childAspectRatio`) keeps every
    // card the same height regardless of the grid's width — with an
    // aspect-ratio-locked height, a narrower device (or a larger system font
    // size) shrinks the card's height right along with its width, while a
    // two-line name plus the flag need a near-fixed minimum height, which
    // overflowed the card on anything narrower than the widest phones.
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: Country.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 116,
      ),
      itemBuilder: (context, index) {
        final country = Country.all[index];
        final isSelected = country == selected;
        return MdCard(
          selected: isSelected,
          onTap: () => onSelected(country),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                country.shortName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
