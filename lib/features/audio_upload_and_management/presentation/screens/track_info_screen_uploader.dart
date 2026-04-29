part of 'track_info_screen.dart';

class _UploaderCard extends ConsumerWidget {
  const _UploaderCard({required this.item});

  final UploadItem item;

  /// The follow pill should be hidden when the track belongs to the signed-in
  /// user. Ownership is derived from (in priority order):
  ///   1. The local uploads store — any track present here was uploaded by me.
  ///   2. The currently playing bundle's artist id vs. the authenticated user id.
  bool _isOwnUpload(WidgetRef ref) {
    final store = ref.read(globalTrackStoreProvider);
    final currentUserId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.id
        .trim();
    final storeOwner = store.ownerUserIdForTrack(item.id)?.trim();
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        storeOwner != null &&
        storeOwner.isNotEmpty &&
        storeOwner != '__global__') {
      return currentUserId == storeOwner;
    }

    final bundle = ref.read(playerProvider).asData?.value.bundle;
    final bundleArtistId = (bundle != null && bundle.trackId == item.id)
        ? bundle.artist.id.trim()
        : '';
    if (bundleArtistId.isEmpty) return false;
    if (currentUserId == null || currentUserId.isEmpty) return false;

    return currentUserId == bundleArtistId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = _isOwnUpload(ref);
    final profileAsync = ref.watch(_trackInfoArtistProfileProvider(item.id));
    final profile = profileAsync.asData?.value;
    final displayName = _displayProfileName(profile, item);
    final location = _displayProfileLocation(profile);
    final avatarUrl = profile?.profileImagePath?.trim().isNotEmpty == true
        ? profile!.profileImagePath
        : item.artworkUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          _ArtistAvatar(avatarUrl: avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              key: const Key('track_info_uploader_artist_tap'),
              onTap: () {
                final artistId = _resolveTrackArtistId(ref, item.id);
                if (artistId == null || artistId.isEmpty) return;

                final currentUserId = ref
                    .read(authControllerProvider)
                    .value
                    ?.id;
                navigateToProfile(
                  context,
                  artistId,
                  currentUserId: currentUserId,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty)
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isOwn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final safeUrl = avatarUrl?.trim();

    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF5D6),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: safeUrl != null && safeUrl.isNotEmpty
          ? Image.network(
              safeUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => const Center(
                child: Icon(
                  Icons.music_note,
                  color: Color(0xFFB8860B),
                  size: 36,
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.music_note, color: Color(0xFFB8860B), size: 36),
            ),
    );
  }
}
