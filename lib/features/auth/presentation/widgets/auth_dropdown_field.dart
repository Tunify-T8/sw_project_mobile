import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';

/// A styled dropdown selector used in auth forms.
///
/// Generic over [T] so it works for both [String] items (month, gender)
/// and [int] items (day, year) without duplication.
///
/// Currently used in [TellUsMoreScreen] for date of birth and gender fields.
///
/// Usage:
/// ```dart
/// AuthDropdownField<String>(
///   hint: 'Month',
///   value: _selectedMonth,
///   items: _months,
///   itemLabel: (m) => m,
///   onChanged: (v) => setState(() => _selectedMonth = v),
/// )
/// ```
class AuthDropdownField<T> extends StatelessWidget {
  /// Placeholder text shown when no value is selected.
  final String hint;

  /// The currently selected value, or null if nothing is selected.
  final T? value;

  /// The list of items to display.
  final List<T> items;

  /// Converts an item to its display label string.
  final String Function(T) itemLabel;

  /// Called when the user selects a value.
  final ValueChanged<T?> onChanged;

  const AuthDropdownField({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: AppTextStyles.inputHint),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.inputText,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.onBackgroundMuted,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
