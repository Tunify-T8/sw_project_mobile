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

/// Collects username, date of birth, and gender before calling
/// [AuthController.register].
class TellUsMoreScreen extends ConsumerStatefulWidget {
  /// Email from the previous registration step.
  final String email;

  /// Password from the previous registration step.
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

  String? _selectedMonth;
  int? _selectedDay;
  int? _selectedYear;
  String? _selectedGender;

  // ── Static lookup tables ──────────────────────────────────────────────────

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
  /// February gets 28; leap-year edge cases are handled server-side.
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

  /// Maps human-readable label → backend enum value.
  static const _genderOptions = {
    'Male': 'MALE',
    'Female': 'FEMALE',
    'Non-binary': 'OTHER',
    'Prefer not to say': 'PREFER_NOT_TO_SAY',
  };

  // ── Computed properties ───────────────────────────────────────────────────

  /// Minimum age is 13 years; list covers 100 years.
  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(100, (i) => now - 13 - i);
  }

  /// Valid day numbers for the currently selected month.
  /// Falls back to 1–31 when no month is selected.
  List<int> get _daysForSelectedMonth {
    if (_selectedMonth == null) return List.generate(31, (i) => i + 1);
    final max = _daysInMonth[_selectedMonth] ?? 31;
    return List.generate(max, (i) => i + 1);
  }

  // ── Reactive validity ─────────────────────────────────────────────────────

  /// `true` when the typed username passes [Validators.username].
  bool get _usernameValid =>
      Validators.username(_usernameController.text) == null;

  /// `true` when all three DOB dropdowns have a selection.
  bool get _dobComplete =>
      _selectedMonth != null && _selectedDay != null && _selectedYear != null;

  /// `true` when a gender option is selected.
  bool get _genderSelected => _selectedGender != null;

  /// `true` when every required field is valid — enables the Continue button.
  bool get _canContinue => _usernameValid && _dobComplete && _genderSelected;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so _canContinue stays in sync with the field.
    _usernameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Builds the ISO-8601 date string (YYYY-MM-DD) from the dropdown values.
  /// Returns `null` if any part is unset (guarded by [_dobComplete]).
  String _buildDob() {
    final month = _monthNumbers[_selectedMonth]!;
    final day = _selectedDay!.toString().padLeft(2, '0');
    return '$_selectedYear-$month-$day';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Submits registration. Guard is redundant (button is `null` when
  /// `!_canContinue`) but kept as a safety net.
  Future<void> _onContinue() async {
    if (!_canContinue) return;

    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: widget.email,
          password: widget.password,
          username: _usernameController.text.trim(),
          gender: _genderOptions[_selectedGender]!,
          dateOfBirth: _buildDob(),
        );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
                    // ── Display name / username field ──────────────────
                    // Key: AuthKeys.displayNameField
                    AppTextField(
                      key: const Key('display_name_field'),
                      controller: _usernameController,
                      hintText: 'Display name',
                      validator: Validators.username,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your display name can be anything you like. '
                      'Your name or artist name are good choices.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Note: only letters, numbers, and underscores are allowed '
                      '(e.g. robin_banks instead of Robin Banks).',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Date of birth ──────────────────────────────────
                    Text(
                      'Date of birth (required)',
                      style: AppTextStyles.fieldLabel,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: AuthDropdownField<String>(
                            key: const Key('dob_month_dropdown'),
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
                            key: const Key('dob_day_dropdown'),
                            hint: 'Day',
                            value: _selectedDay,
                            items: _daysForSelectedMonth,
                            itemLabel: (d) => d.toString(),
                            onChanged: (v) => setState(() => _selectedDay = v),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 4,
                          child: AuthDropdownField<int>(
                            key: const Key('dob_year_dropdown'),
                            hint: 'Year',
                            value: _selectedYear,
                            items: _years,
                            itemLabel: (y) => y.toString(),
                            onChanged: (v) => setState(() => _selectedYear = v),
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

                    // ── Gender ─────────────────────────────────────────
                    AuthDropdownField<String>(
                      key: const Key('gender_dropdown'),
                      hint: 'Gender (required)',
                      value: _selectedGender,
                      items: _genderOptions.keys.toList(),
                      itemLabel: (g) => g,
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Continue button ────────────────────────────────
                    // Disabled (grey) until username is valid AND all DOB
                    // fields AND gender are selected.
                    // Key: AuthKeys.tellUsMoreContinueButton
                    AppButton(
                      key: const Key('tell_us_more_continue_button'),
                      label: 'Continue',
                      onPressed: _canContinue ? _onContinue : null,
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
    );
  }
}
