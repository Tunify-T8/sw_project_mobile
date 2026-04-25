import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../utils/search_track_playback.dart';
import '../widgets/search/search_result_tile_album.dart';
import '../widgets/search/search_result_tile_playlist.dart';
import '../widgets/search/search_result_tile_profile.dart';
import '../widgets/search/search_result_tile_track.dart';

/// Full-list screen shown when the user taps "See all" in a search section.
///
/// FIX: Profile tiles now navigate to [OtherUserProfileScreen] on tap.
/// Previously [SearchResultTileProfile] was rendered with no [onTap] here.
class SearchSeeAllScreen extends ConsumerWidget {
  const SearchSeeAllScreen({
    super.key,
    required this.title,
    this.tracks = const [],
    this.profiles = const [],
    this.playlists = const [],
    this.albums = const [],
  });

  final String title;
  final List<TrackResultEntity> tracks;
  final List<ProfileResultEntity> profiles;
  final List<PlaylistResultEntity> playlists;
  final List<AlbumResultEntity> albums;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    if (tracks.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length,
        itemBuilder: (_, i) {
          final track = tracks[i];
          return SearchResultTileTrack(
            track: track,
            onTap: () =>
                playSearchTrack(context, ref, track, queueTracks: tracks),
          );
        },
      );
    }

    if (playlists.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: playlists.length,
        itemBuilder: (_, i) => SearchResultTilePlaylist(playlist: playlists[i]),
      );
    }

    if (profiles.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: profiles.length,
        itemBuilder: (_, i) {
          final profile = profiles[i];
          return SearchResultTileProfile(
            profile: profile,
            // FIX: was missing onTap — profiles now navigate to profile screen
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtherUserProfileScreen(userId: profile.id),
              ),
            ),
          );
        },
      );
    }

    if (albums.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: albums.length,
        itemBuilder: (_, i) => SearchResultTileAlbum(album: albums[i]),
      );
    }

    return const Center(
      child: Text('Nothing to show.', style: TextStyle(color: Colors.white54)),
    );
  }
}
