import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class FilterChipsPanel extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const FilterChipsPanel({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: AppColors.surfaceElevated,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected
                    ? AppColors.outline
                    : AppColors.divider,
                width: 1.5,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}