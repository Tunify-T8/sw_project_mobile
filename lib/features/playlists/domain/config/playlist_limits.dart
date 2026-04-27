const int kFreeCollectionLimit = 2;

String freeCollectionLimitMessage([int limit = kFreeCollectionLimit]) {
  return 'Free users can only create up to $limit playlists.';
}

String playlistLimitReachedMessage(
  int limit, {
  bool includeUpgradeHint = false,
}) {
  final base = 'Not able to add more playlists. Your limit is $limit playlists. Upgrade to premium for an increased limit.';
  if (!includeUpgradeHint) return base;
  return '$base Upgrade to premium to increase the limit.';
}

bool hasReachedFreeCollectionLimit(
  int currentCount, {
  int limit = kFreeCollectionLimit,
}) {
  return currentCount >= limit;
}
