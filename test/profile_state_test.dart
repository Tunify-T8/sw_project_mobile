import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/profile/presentation/providers/profile_state.dart';
import 'package:software_project/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('ProfileState', () {
    test('initial state is correct', () {
      const state = ProfileState();

      expect(state.status, ProfileStatus.initial);
      expect(state.profile, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.isError, false);
    });

    test('isLoading is true when status is loading', () {
      const state = ProfileState(status: ProfileStatus.loading);
      expect(state.isLoading, true);
      expect(state.isSuccess, false);
      expect(state.isError, false);
    });

    test('isSuccess is true when status is success', () {
      const state = ProfileState(status: ProfileStatus.success);
      expect(state.isSuccess, true);
      expect(state.isLoading, false);
      expect(state.isError, false);
    });

    test('isError is true when status is error', () {
      const state = ProfileState(
        status: ProfileStatus.error,
        errorMessage: 'Something went wrong',
      );
      expect(state.isError, true);
      expect(state.errorMessage, 'Something went wrong');
    });

    test('copyWith updates status only', () {
      const state = ProfileState();
      final updated = state.copyWith(status: ProfileStatus.loading);

      expect(updated.status, ProfileStatus.loading);
      expect(updated.profile, null);
      expect(updated.errorMessage, null);
    });

    test('copyWith preserves old values when not provided', () {
      const state = ProfileState(
        status: ProfileStatus.success,
        errorMessage: 'old error',
      );
      final updated = state.copyWith(status: ProfileStatus.error);

      expect(updated.status, ProfileStatus.error);
      expect(updated.errorMessage, 'old error');
    });
  });
}