part of 'track_info_screen.dart';

class _ArtistPlaylistsSection extends ConsumerWidget {
  const _ArtistPlaylistsSection({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_trackInfoArtistProfileProvider(item.id));
    final profile = profileAsync.asData?.value;
    final username = profile?.userName.trim() ?? '';
    final playlistsAsync = username.isEmpty
        ? const AsyncData(<PlaylistSummaryEntity>[])
        : ref.watch(_artistPublicPlaylistsProvider(username));
    final playlists = playlistsAsync.asData?.value ?? const [];
    final ownerName = _displayProfileName(profile, item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In Playlists',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          if (profileAsync.isLoading || playlistsAsync.isLoading)
            const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 16, bottom: 22),
              child: Text(
                'No public playlists yet',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            )
          else
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                padding: const EdgeInsets.only(right: 16),
                separatorBuilder: (_, index) => const SizedBox(width: 18),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return _ArtistPlaylistCard(
                    playlist: playlist,
                    ownerName: ownerName,
                    onTap: () => Navigator.of(context).pushNamed(
                      Routes.playlistDetail,
                      arguments: {
                        'playlistId': playlist.id,
                        'isMine': playlist.isMine,
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ArtistPlaylistCard extends StatelessWidget {
  const _ArtistPlaylistCard({
    required this.playlist,
    required this.ownerName,
    required this.onTap,
  });

  final PlaylistSummaryEntity playlist;
  final String ownerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 210,
                height: 150,
                child:
                    playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty
                    ? Image.network(
                        playlist.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stack) =>
                            const _PlaylistPlaceholder(),
                      )
                    : const _PlaylistPlaceholder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ownerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistPlaceholder extends StatelessWidget {
  const _PlaylistPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      alignment: Alignment.center,
      child: const Icon(
        Icons.queue_music_rounded,
        color: Colors.white24,
        size: 40,
      ),
    );
  }
}
