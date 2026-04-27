import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/entities/playlist_track_entity.dart';


class PlaylistState {
  // ─── My collections list 
  final List<PlaylistSummaryEntity> myCollections;
  final bool isMyCollectionsLoading;
  final String? myCollectionsError;
  final bool hasMoreMyCollections;
  final int myCollectionsPage;

  // ─── Active detail ───────────────────────────────────────────────────────
  final PlaylistEntity? activePlaylist;
  final List<PlaylistTrackEntity> activeTracks;
  final bool isDetailLoading;
  final String? detailError;

  // ─── Track list pagination ────────────────────────────────────────────────
  final bool isTracksLoading;
  final bool hasMoreTracks;
  final int tracksPage;

  // ─── Mutating operations ─────────────────────────────────────────────────
  final bool isMutating; // create / edit / delete / add / remove / reorder
  final String? mutationError;

  const PlaylistState({
    this.myCollections = const [],
    this.isMyCollectionsLoading = false,
    this.myCollectionsError,
    this.hasMoreMyCollections = false,
    this.myCollectionsPage = 1,
    this.activePlaylist,
    this.activeTracks = const [],
    this.isDetailLoading = false,
    this.detailError,
    this.isTracksLoading = false,
    this.hasMoreTracks = false,
    this.tracksPage = 1,
    this.isMutating = false,
    this.mutationError,
  });

  PlaylistState copyWith({
    List<PlaylistSummaryEntity>? myCollections,
    bool? isMyCollectionsLoading,
    String? myCollectionsError,
    bool clearMyCollectionsError = false,
    bool? hasMoreMyCollections,
    int? myCollectionsPage,
    PlaylistEntity? activePlaylist,
    bool clearActivePlaylist = false,
    List<PlaylistTrackEntity>? activeTracks,
    bool? isDetailLoading,
    String? detailError,
    bool clearDetailError = false,
    bool? isTracksLoading,
    bool? hasMoreTracks,
    int? tracksPage,
    bool? isMutating,
    String? mutationError,
    bool clearMutationError = false,
  }) {
    return PlaylistState(
      myCollections: myCollections ?? this.myCollections,
      isMyCollectionsLoading:
          isMyCollectionsLoading ?? this.isMyCollectionsLoading,
      myCollectionsError: clearMyCollectionsError
          ? null
          : (myCollectionsError ?? this.myCollectionsError),
      hasMoreMyCollections: hasMoreMyCollections ?? this.hasMoreMyCollections,
      myCollectionsPage: myCollectionsPage ?? this.myCollectionsPage,
      activePlaylist: clearActivePlaylist
          ? null
          : (activePlaylist ?? this.activePlaylist),
      activeTracks: activeTracks ?? this.activeTracks,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      detailError: clearDetailError ? null : (detailError ?? this.detailError),
      isTracksLoading: isTracksLoading ?? this.isTracksLoading,
      hasMoreTracks: hasMoreTracks ?? this.hasMoreTracks,
      tracksPage: tracksPage ?? this.tracksPage,
      isMutating: isMutating ?? this.isMutating,
      mutationError: clearMutationError
          ? null
          : (mutationError ?? this.mutationError),
    );
  }
}
