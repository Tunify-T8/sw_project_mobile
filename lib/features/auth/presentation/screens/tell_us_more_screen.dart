import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_form_fields.dart';

/// Collects display name, date of birth, and gender before
/// calling [AuthController.register].
class TellUsMoreScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const TellUsMoreScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<TellUsMoreScreen> createState() => _TellUsMoreScreenState();
}

class _TellUsMoreScreenState extends ConsumerState<TellUsMoreScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedMonth;
  int? _selectedDay;
  int? _selectedYear;
  String? _selectedGender;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _monthNumbers = {
    'January': '01',
    'February': '02',
    'March': '03',
    'April': '04',
    'May': '05',
    'June': '06',
    'July': '07',
    'August': '08',
    'September': '09',
    'October': '10',
    'November': '11',
    'December': '12',
  };

  /// Days per month for non-leap-year validation.
  /// February gets 28; leap years are an edge case handled by server validation.
  static const _daysInMonth = {
    'January': 31,
    'February': 28,
    'March': 31,
    'April': 30,
    'May': 31,
    'June': 30,
    'July': 31,
    'August': 31,
    'September': 30,
    'October': 31,
    'November': 30,
    'December': 31,
  };

  /// Maps display label → backend enum value.
  static const _genderOptions = {
    'Male': 'MALE',
    'Female': 'FEMALE',
    'Non-binary': 'OTHER',
    'Prefer not to say': 'PREFER_NOT_TO_SAY',
  };

  /// Years ranging from 13 years ago back 100 years (minimum age enforcement).
  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(100, (i) => now - 13 - i);
  }

  /// Returns a list of valid day numbers for the currently selected month.
  ///
  /// If no month is selected, returns 1–31. Used to prevent invalid dates
  /// such as February 30.
  List<int> get _daysForSelectedMonth {
    if (_selectedMonth == null) return List.generate(31, (i) => i + 1);
    final max = _daysInMonth[_selectedMonth] ?? 31;
    return List.generate(max, (i) => i + 1);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /// Builds the ISO date string (YYYY-MM-DD) from the selected dropdowns,
  /// or returns null if any part is missing.
  String? _buildDob() {
    if (_selectedYear == null ||
        _selectedMonth == null ||
        _selectedDay == null) {
      return null;
    }
    final month = _monthNumbers[_selectedMonth]!;
    final day = _selectedDay!.toString().padLeft(2, '0');
    return '$_selectedYear-$month-$day';
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final dob = _buildDob();
    if (dob == null) {
      _snack('Please enter your date of birth.');
      return;
    }
    if (_selectedGender == null) {
      _snack('Please select your gender.');
      return;
    }

    // Always goes through the controller → use case → repository chain.
    // In mock mode, authRepositoryProvider returns MockAuthRepository.
    // In real mode, it returns AuthRepositoryImpl.
    // Navigation and error handling are done via ref.listen in build().
    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: widget.email,
          password: widget.password,
          username: _usernameController.text.trim(),
          gender: _genderOptions[_selectedGender]!,
          dateOfBirth: dob,
        );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // Navigate on successful registration and show errors if they occur.
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyEmail,
              arguments: {'email': widget.email},
            );
          }
        },
        error: (e, _) {
          final msg = e is Failure ? e.message : 'Registration failed.';
          _snack(msg);
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    0,
                  ),
                  child: AppBackButtonRow(title: 'Tell us more about you'),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display name
                      AppTextField(
                        controller: _usernameController,
                        hintText: 'Display name',
                        validator: Validators.displayName,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your display name can be anything you like. '
                        'Your name or artist name are good choices.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'Date of birth (required)',
                        style: AppTextStyles.fieldLabel,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Three dropdowns for month/day/year. The day list updates
                      // based on the selected month to prevent invalid dates.
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: AuthDropdownField<String>(
                              hint: 'Month',
                              value: _selectedMonth,
                              items: _months,
                              itemLabel: (m) => m,
                              onChanged: (v) {
                                setState(() {
                                  _selectedMonth = v;
                                  // Reset day if it exceeds the new month max.
                                  if (_selectedDay != null && v != null) {
                                    final max = _daysInMonth[v] ?? 31;
                                    if (_selectedDay! > max) {
                                      _selectedDay = null;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            flex: 3,
                            child: AuthDropdownField<int>(
                              hint: 'Day',
                              value: _selectedDay,
                              items: _daysForSelectedMonth,
                              itemLabel: (d) => d.toString(),
                              onChanged: (v) =>
                                  setState(() => _selectedDay = v),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            flex: 4,
                            child: AuthDropdownField<int>(
                              hint: 'Year',
                              value: _selectedYear,
                              items: _years,
                              itemLabel: (y) => y.toString(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your date of birth is used to verify your age '
                        'and is not shared publicly.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Gender
                      AuthDropdownField<String>(
                        hint: 'Gender (required)',
                        value: _selectedGender,
                        items: _genderOptions.keys.toList(),
                        itemLabel: (g) => g,
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      AppButton(
                        label: 'Continue',
                        onPressed: _onContinue,
                        style: AppButtonStyle.primary,
                        isLoading: isLoading,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
