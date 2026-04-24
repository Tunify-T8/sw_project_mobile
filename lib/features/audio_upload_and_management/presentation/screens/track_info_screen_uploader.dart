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
    if (store.find(item.id) != null) return true;

    final bundle = ref.read(playerProvider).asData?.value.bundle;
    final bundleArtistId = (bundle != null && bundle.trackId == item.id)
        ? bundle.artist.id.trim()
        : '';
    if (bundleArtistId.isEmpty) return false;

    final currentUserId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.id
        .trim();
    if (currentUserId == null || currentUserId.isEmpty) return false;

    return currentUserId == bundleArtistId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = _isOwnUpload(ref);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5D6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.music_note, color: Color(0xFFB8860B), size: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.artistDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Egypt',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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