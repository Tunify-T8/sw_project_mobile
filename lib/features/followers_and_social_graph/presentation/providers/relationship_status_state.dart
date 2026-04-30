class RelationshipStatusState {
  final bool? isFollowing;
  final bool? isBlocked;
  final bool isLoading;
  final String? error;

  const RelationshipStatusState({
    this.isFollowing,
    this.isBlocked,
    this.isLoading = false,
    this.error,
  });

  RelationshipStatusState copyWith({
    bool? isFollowing,
    bool? isBlocked,
    bool? isLoading,
    String? error,
  }) {
    return RelationshipStatusState(
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}