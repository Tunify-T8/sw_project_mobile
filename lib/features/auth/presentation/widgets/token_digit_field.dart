import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:software_project/core/design_system/colors.dart';

/// A single character input box for 6-digit verification or reset token entry.
///
/// Features:
/// - Accepts only alphanumeric characters.
/// - Automatically advances focus to the next field when a character is entered.
/// - Returns focus to the previous field on backspace if the current box is empty.
/// - Uppercases all input so the token is always sent correctly.
///
/// Used in [VerifyEmailScreen] to build the 6-box token input row.
///
/// Usage — build 6 of these in a [Row]:
/// ```dart
/// Row(
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: List.generate(6, (i) => TokenDigitField(
///     controller: _controllers[i],
///     focusNode: _focusNodes[i],
///     onChanged: (v) {
///       if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
///       setState(() {});
///     },
///     onBackspace: () {
///       if (_controllers[i].text.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
///     },
///   )),
/// )
/// ```
class TokenDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  /// Called when the character in this box changes.
  final ValueChanged<String> onChanged;

  /// Called when backspace is pressed and this box is already empty,
  /// so the parent can move focus to the previous box.
  final VoidCallback onBackspace;

  const TokenDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: KeyboardListener(
        // Separate FocusNode so keyboard events don't interfere with the field.
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
          cursorColor: AppColors.onBackground,
          onChanged: onChanged,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.onBackground,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
