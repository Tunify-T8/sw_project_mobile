import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/relationship_status_state.dart';

void main() {
  test('copyWith updates provided values and clears error by default', () {
    const state = RelationshipStatusState(
      isFollowing: false,
      isBlocked: false,
      isLoading: true,
      error: 'old',
    );

    final updated = state.copyWith(
      isFollowing: true,
      isBlocked: true,
      isLoading: false,
    );

    expect(updated.isFollowing, isTrue);
    expect(updated.isBlocked, isTrue);
    expect(updated.isLoading, isFalse);
    expect(updated.error, isNull);
  });

  test('copyWith preserves nullable status values when omitted', () {
    const state = RelationshipStatusState(
      isFollowing: true,
      isBlocked: false,
    );

    final updated = state.copyWith(error: 'failed');

    expect(updated.isFollowing, isTrue);
    expect(updated.isBlocked, isFalse);
    expect(updated.error, 'failed');
  });
}
