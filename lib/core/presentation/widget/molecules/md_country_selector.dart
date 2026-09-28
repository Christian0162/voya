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
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: Country.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final country = Country.all[index];
        final isSelected = country == selected;
        return MdCard(
          selected: isSelected,
          onTap: () => onSelected(country),
          child: Row(
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  country.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
