import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/paginated_playlists.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/usecases/playlist_usecases.dart';
import 'playlist_providers.dart';
import 'playlist_state.dart';

/// Drives all playlist / collection UI through a single [PlaylistState].
///
/// Uses Riverpod 2.x [Notifier] — dependencies are resolved via [ref] in
/// [build], matching the pattern used throughout this project.
class PlaylistNotifier extends Notifier<PlaylistState> {
  late final CreatePlaylistUseCase _createPlaylist;
  late final EditPlaylistUseCase _editPlaylist;
  late final DeletePlaylistUseCase _deletePlaylist;
  late final GetPlaylistUseCase _getPlaylist;
  late final GetMyPlaylistsUseCase _getMyPlaylists;
  late final GetTracksPerPlaylistUseCase _getTracksPerPlaylist;
  late final ReorderTracksUseCase _reorderTracks;
  late final AddTrackUseCase _addTrack;
  late final RemoveTrackUseCase _removeTrack;

  @override
  PlaylistState build() {
    _createPlaylist = ref.read(createPlaylistUseCaseProvider);
    _editPlaylist = ref.read(editPlaylistUseCaseProvider);
    _deletePlaylist = ref.read(deletePlaylistUseCaseProvider);
    _getPlaylist = ref.read(getPlaylistUseCaseProvider);
    _getMyPlaylists = ref.read(getMyPlaylistsUseCaseProvider);
    _getTracksPerPlaylist = ref.read(getTracksPerPlaylistUseCaseProvider);
    _reorderTracks = ref.read(reorderTracksUseCaseProvider);
    _addTrack = ref.read(addTrackUseCaseProvider);
    _removeTrack = ref.read(removeTrackUseCaseProvider);
    return const PlaylistState();
  }

  // ─── My Collections list ─────────────────────────────────────────────────

  Future<void> loadMyCollections({CollectionType? type, int limit = 20}) async {
    state = state.copyWith(
      isMyCollectionsLoading: true,
      clearMyCollectionsError: true,
    );
    try {
      final result = await _getMyPlaylists(page: 1, limit: limit, type: type);
      state = state.copyWith(
        myCollections: result.items,
        isMyCollectionsLoading: false,
        hasMoreMyCollections: result.hasMore,
        myCollectionsPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isMyCollectionsLoading: false,
        myCollectionsError: e.toString(),
      );
    }
  }

  Future<void> loadMoreMyCollections({
    CollectionType? type,
    int limit = 20,
  }) async {
    if (!state.hasMoreMyCollections || state.isMyCollectionsLoading) return;
    final nextPage = state.myCollectionsPage + 1;
    state = state.copyWith(isMyCollectionsLoading: true);
    try {
      final result = await _getMyPlaylists(
        page: nextPage,
        limit: limit,
        type: type,
      );
      state = state.copyWith(
        myCollections: [...state.myCollections, ...result.items],
        isMyCollectionsLoading: false,
        hasMoreMyCollections: result.hasMore,
        myCollectionsPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isMyCollectionsLoading: false,
        myCollectionsError: e.toString(),
      );
    }
  }

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<void> openPlaylist(String id) async {
    state = state.copyWith(
      isDetailLoading: true,
      clearDetailError: true,
      activeTracks: [],
      tracksPage: 1,
    );
    try {
      final results = await Future.wait([
        _getPlaylist(id),
        _getTracksPerPlaylist(playlistId: id, limit: 50),
      ]);
      final playlist = results[0] as PlaylistEntity;
      final tracks = results[1] as PaginatedPlaylistTracks;
      state = state.copyWith(
        activePlaylist: playlist,
        activeTracks: tracks.items,
        hasMoreTracks: tracks.hasMore,
        isDetailLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isDetailLoading: false, detailError: e.toString());
    }
  }

  // ─── Create ──────────────────────────────────────────────────────────────

  Future<PlaylistEntity?> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      final created = await _createPlaylist(
        title: title,
        type: type,
        privacy: privacy,
        description: description,
        cover: cover,
        coverUrl: coverUrl,
      );
      state = state.copyWith(
        isMutating: false,
        myCollections: [_toSummary(created), ...state.myCollections],
      );
      return created;
    } on DioException catch (e) {
      debugPrint('CREATE PLAYLIST URL: ${e.requestOptions.uri}');
      debugPrint('CREATE PLAYLIST METHOD: ${e.requestOptions.method}');
      debugPrint('CREATE PLAYLIST DATA: ${e.requestOptions.data}');
      debugPrint('CREATE PLAYLIST QUERY: ${e.requestOptions.queryParameters}');
      debugPrint('CREATE PLAYLIST RESPONSE: ${e.response?.data}');
      final responseData = e.response?.data;
      final responseMessage = responseData is Map<String, dynamic>
          ? responseData['message']?.toString()
          : null;
      state = state.copyWith(
        isMutating: false,
        mutationError: responseMessage ?? e.message ?? e.toString(),
      );
      return null;
    } catch (e) {
      state = state.copyWith(isMutating: false, mutationError: e.toString());
      return null;
    }
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────

  Future<void> editCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      final updated = await _editPlaylist(
        id: id,
        title: title,
        description: description,
        privacy: privacy,
        cover: cover,
        coverUrl: coverUrl,
      );
      final refreshedActive = state.activePlaylist?.id == id
          ? updated
          : state.activePlaylist;
      final updatedList = state.myCollections
          .map((s) => s.id == id ? _toSummary(updated) : s)
          .toList();
      state = state.copyWith(
        isMutating: false,
        activePlaylist: refreshedActive,
        myCollections: updatedList,
      );
    } catch (e) {
      state = state.copyWith(isMutating: false, mutationError: e.toString());
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteCollection(String id) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      await _deletePlaylist(id);
      state = state.copyWith(
        isMutating: false,
        myCollections: state.myCollections.where((s) => s.id != id).toList(),
        clearActivePlaylist: state.activePlaylist?.id == id,
      );
    } catch (e) {
      state = state.copyWith(isMutating: false, mutationError: e.toString());
    }
  }

  // ─── Add track ────────────────────────────────────────────────────────────

  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      await _addTrack(collectionId: collectionId, trackId: trackId);
      await openPlaylist(collectionId);
      state = state.copyWith(isMutating: false);
    } catch (e) {
      state = state.copyWith(isMutating: false, mutationError: e.toString());
    }
  }

  // ─── Remove track ─────────────────────────────────────────────────────────

  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  }) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      await _removeTrack(collectionId: collectionId, trackId: trackId);
      final remaining = state.activeTracks
          .where((t) => t.trackId != trackId)
          .toList();
      state = state.copyWith(isMutating: false, activeTracks: remaining);
    } catch (e) {
      state = state.copyWith(isMutating: false, mutationError: e.toString());
    }
  }

// ─── Reorder tracks ───────────────────────────────────────────────────────

  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  }) async {
    final byId = {for (final t in state.activeTracks) t.trackId: t};
    final reordered = [
      for (final id in trackIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
    final firstTrackCoverUrl =
        reordered.isNotEmpty ? reordered.first.coverUrl : null;
    final optimisticPlaylist = state.activePlaylist?.id == collectionId
        ? _copyPlaylistWithCover(state.activePlaylist!, firstTrackCoverUrl)
        : state.activePlaylist;
    final optimisticCollections = state.myCollections
        .map(
          (playlist) => playlist.id == collectionId
              ? _copySummaryWithCover(playlist, firstTrackCoverUrl)
              : playlist,
        )
        .toList();

    state = state.copyWith(
      activeTracks: reordered,
      activePlaylist: optimisticPlaylist,
      myCollections: optimisticCollections,
    );

    try {
      await _reorderTracks(collectionId: collectionId, trackIds: trackIds);

      final updatedPlaylist = await _getPlaylist(collectionId);
      final syncedPlaylist =
          _copyPlaylistWithCover(updatedPlaylist, firstTrackCoverUrl);
      state = state.copyWith(
        activePlaylist: syncedPlaylist,
        myCollections: state.myCollections
            .map(
              (playlist) => playlist.id == collectionId
                  ? _copySummaryWithCover(
                      _toSummary(updatedPlaylist),
                      firstTrackCoverUrl,
                    )
                  : playlist,
            )
            .toList(),
      );
    } catch (e) {
      await openPlaylist(collectionId);
      state = state.copyWith(mutationError: e.toString());
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  PlaylistSummaryEntity _toSummary(PlaylistEntity e) => PlaylistSummaryEntity(
    id: e.id,
    title: e.title,
    description: e.description,
    type: e.type,
    privacy: e.privacy,
    coverUrl: e.coverUrl,
    trackCount: e.trackCount,
    likeCount: e.likeCount,
    repostsCount: e.repostsCount,
    ownerFollowerCount: e.ownerFollowerCount,
    isMine: true, // created by current user
    isLiked: e.isLiked,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  PlaylistEntity _copyPlaylistWithCover(
    PlaylistEntity playlist,
    String? coverUrl,
  ) {
    return PlaylistEntity(
      id: playlist.id,
      title: playlist.title,
      description: playlist.description,
      type: playlist.type,
      privacy: playlist.privacy,
      secretToken: playlist.secretToken,
      coverUrl: coverUrl,
      trackCount: playlist.trackCount,
      likeCount: playlist.likeCount,
      repostsCount: playlist.repostsCount,
      ownerFollowerCount: playlist.ownerFollowerCount,
      isLiked: playlist.isLiked,
      owner: playlist.owner,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }

  PlaylistSummaryEntity _copySummaryWithCover(
    PlaylistSummaryEntity playlist,
    String? coverUrl,
  ) {
    return PlaylistSummaryEntity(
      id: playlist.id,
      title: playlist.title,
      description: playlist.description,
      type: playlist.type,
      privacy: playlist.privacy,
      coverUrl: coverUrl,
      trackCount: playlist.trackCount,
      likeCount: playlist.likeCount,
      repostsCount: playlist.repostsCount,
      ownerFollowerCount: playlist.ownerFollowerCount,
      isMine: playlist.isMine,
      isLiked: playlist.isLiked,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }
}
