import 'package:flutter/material.dart';

import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../widgets/search/search_result_tile_track.dart';
import '../widgets/search/search_result_tile_playlist.dart';
import '../widgets/search/search_result_tile_profile.dart';
import '../widgets/search/search_result_tile_album.dart';

class SearchSeeAllScreen extends StatelessWidget {
  const SearchSeeAllScreen({
    super.key,
    required this.title,
    this.tracks = const [],
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });

  final String title;
  final List<TrackResultEntity> tracks;
  final List<PlaylistResultEntity> playlists;
  final List<ProfileResultEntity> profiles;
  final List<AlbumResultEntity> albums;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    if (tracks.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length,
        itemBuilder: (_, i) => SearchResultTileTrack(track: tracks[i]),
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
        itemBuilder: (_, i) => SearchResultTileProfile(profile: profiles[i]),
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
