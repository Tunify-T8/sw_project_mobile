const int kFreeCollectionLimit = 2;

String freeCollectionLimitMessage([int limit = kFreeCollectionLimit]) {
  return 'Free users can only create up to $limit playlists.';
}

bool hasReachedFreeCollectionLimit(
  int currentCount, {
  int limit = kFreeCollectionLimit,
}) {
  return currentCount >= limit;
}
