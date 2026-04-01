part of 'track_info_screen.dart';

class _PlaylistsSection extends StatelessWidget {
  const _PlaylistsSection({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    final playlists = _mockPlaylists(item);

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
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              padding: const EdgeInsets.only(right: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return SizedBox(
                  width: 210,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 210,
                          height: 150,
                          child:
                              index == 0 &&
                                  (item.localArtworkPath != null ||
                                      item.artworkUrl != null)
                              ? UploadArtworkView(
                                  localPath: item.localArtworkPath,
                                  remoteUrl: item.artworkUrl,
                                  width: 210,
                                  height: 150,
                                  borderRadius: BorderRadius.zero,
                                  placeholder: Container(color: playlist.color),
                                )
                              : Container(
                                  color: playlist.color,
                                  alignment: Alignment.center,
                                  child: Text(
                                    playlist.emoji,
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
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
                        playlist.owner,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
