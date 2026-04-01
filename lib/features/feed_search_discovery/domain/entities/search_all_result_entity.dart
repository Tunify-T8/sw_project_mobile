import 'top_result_entity.dart';
import 'track_result_entity.dart';
import 'playlist_result_entity.dart';
import 'profile_result_entity.dart';
import 'album_result_entity.dart';

// ─── "All" tab aggregate result ───────────────────────────────────────────────
class SearchAllResultEntity {
  final TopResultEntity? topResult;
  final List<TrackResultEntity> tracks;
  final List<PlaylistResultEntity> playlists;
  final List<ProfileResultEntity> profiles;
  final List<AlbumResultEntity> albums;

  const SearchAllResultEntity({
    this.topResult,
    this.tracks = const [],
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });
}
