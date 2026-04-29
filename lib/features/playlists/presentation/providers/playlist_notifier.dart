import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/network_exceptions.dart';
import '../../../premium_subscription/presentation/providers/subscription_notifier.dart';
import '../../domain/config/playlist_limits.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/paginated_playlists.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/usecases/playlist_usecases.dart';
import 'playlist_providers.dart';
import 'playlist_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Drives all playlist / collection UI through a single [PlaylistState].
///
/// Uses Riverpod 2.x [Notifier] — dependencies are resolved via [ref] in
/// [build], matching the pattern used throughout this project.
class PlaylistNotifier extends Notifier<PlaylistState> {
  late final PlaylistRepository _repository;
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
    _repository = ref.read(playlistRepositoryProvider);
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
        myCollectionsError: _fetchErrorMessage(e),
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
        myCollectionsError: _fetchErrorMessage(e),
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
      state = state.copyWith(
        isDetailLoading: false,
        detailError: _fetchErrorMessage(e),
      );
    }
  }

  Future<void> openPlaylistByToken(String token) async {
    state = state.copyWith(
      isDetailLoading: true,
      clearDetailError: true,
      activeTracks: [],
      tracksPage: 1,
    );
    try {
      final playlist = await _repository.getCollectionByToken(token);
      final tracks = await _getTracksPerPlaylist(
        playlistId: playlist.id,
        limit: 50,
      );
      state = state.copyWith(
        activePlaylist: playlist,
        activeTracks: tracks.items,
        hasMoreTracks: tracks.hasMore,
        isDetailLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDetailLoading: false,
        detailError: _fetchErrorMessage(e),
      );
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
      final playlistLimit = await _getPlaylistLimit();
      if (playlistLimit != -1) {
        final latestCollections = await _getMyPlaylists(
          page: 1,
          limit: 1,
          type: type,
        );
        if (latestCollections.total >= playlistLimit) {
          state = state.copyWith(
            isMutating: false,
            mutationError: playlistLimitReachedMessage(
              playlistLimit,
              includeUpgradeHint: true,
            ),
          );
          return null;
        }
      }

      final created = await _createPlaylist(
        title: title,
        type: type,
        privacy: privacy,
        description: description,
        cover: cover,
        coverUrl: coverUrl,
      );
      final refreshedCollections = await _getMyPlaylists(page: 1, limit: 20);
      state = state.copyWith(
        isMutating: false,
        myCollections: refreshedCollections.items,
        hasMoreMyCollections: refreshedCollections.hasMore,
        myCollectionsPage: refreshedCollections.page,
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
      state = state.copyWith(
        isMutating: false,
        mutationError: _actionErrorMessage(e),
      );
      return null;
    }
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────

  Future<void> editCollection({
    required String id,
    CollectionType? type,
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
        type: type,
        title: title,
        description: description,
        privacy: privacy,
        cover: cover,
        coverUrl: coverUrl,
      );
      final refreshedActive = state.activePlaylist?.id == id
          ? updated
          : state.activePlaylist;
      final updatedSummary = _toSummary(updated);
      final updatedList = state.myCollections
          .map((s) => s.id == id ? updatedSummary : s)
          .where((s) => s.id != id || updated.id == id || s.id == updated.id)
          .toList();
      if (!updatedList.any((s) => s.id == updated.id)) {
        updatedList.insert(0, updatedSummary);
      }
      state = state.copyWith(
        isMutating: false,
        activePlaylist: refreshedActive,
        myCollections: updatedList,
      );
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        mutationError: _actionErrorMessage(e),
      );
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
      state = state.copyWith(
        isMutating: false,
        mutationError: _actionErrorMessage(e),
      );
    }
  }

  // ─── Add track ────────────────────────────────────────────────────────────

  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) async {
    state = state.copyWith(isMutating: true, clearMutationError: true);
    try {
      final active = state.activePlaylist;
      if (active != null &&
          active.id == collectionId &&
          active.type == CollectionType.album) {
        final role = _currentUserRole();
        if (role != 'ARTIST') {
          state = state.copyWith(
            isMutating: false,
            mutationError: 'Only artists can add tracks to albums',
          );
          return;
        }
      }
      await _addTrack(collectionId: collectionId, trackId: trackId);
      await openPlaylist(collectionId);
      state = state.copyWith(isMutating: false);
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        mutationError: _actionErrorMessage(e),
      );
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
      state = state.copyWith(
        isMutating: false,
        mutationError: _actionErrorMessage(e),
      );
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
      state = state.copyWith(mutationError: _actionErrorMessage(e));
    }
  }

  // ─── Like / Unlike ──────────────────────────────────────────────────────────

  Future<void> toggleLike(String id, {required bool currentlyLiked}) async {
    final playlist = state.activePlaylist;
    if (playlist?.id == id) {
      state = state.copyWith(
        activePlaylist: _withIsLiked(playlist!, !currentlyLiked),
      );
    }
    try {
      if (currentlyLiked) {
        await _repository.unlikeCollection(id);
      } else {
        await _repository.likeCollection(id);
      }
    } catch (e) {
      if (state.activePlaylist?.id == id) {
        state = state.copyWith(
          activePlaylist: _withIsLiked(state.activePlaylist!, currentlyLiked),
          mutationError: _actionErrorMessage(e),
        );
      }
    }
  }

  Future<void> convertToAlbum(String id) async {
    final role = _currentUserRole();
    if (role != 'ARTIST') {
      state = state.copyWith(mutationError: 'Only artists can create albums');
      return;
    }

    final active = state.activePlaylist;
    final tracks = (active != null && active.id == id)
        ? state.activeTracks
        : (await _getTracksPerPlaylist(playlistId: id, limit: 200)).items;
    final currentUserId = _currentUserId();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      final notOwned = tracks
          .where((track) => track.ownerId.trim() != currentUserId)
          .toList(growable: false);
      if (notOwned.isNotEmpty) {
        state = state.copyWith(
          mutationError:
              'Cannot convert to album: ${notOwned.length} track(s) do not belong to you. Remove them first before converting to an album.',
        );
        return;
      }
    }
    await editCollection(id: id, type: CollectionType.album);
  }

  Future<void> convertToPlaylist(String id) async {
    await editCollection(id: id, type: CollectionType.playlist);
  }

  String _fetchErrorMessage(Object error) {
    if (error is DioException) {
      final failure = NetworkExceptions.fromDioException(error);
      if (failure is ValidationFailure ||
          failure is UnauthorizedFailure ||
          failure is ForbiddenFailure ||
          failure is ConflictFailure) {
        return 'Action not permissible.';
      }
      return 'Could not fetch data. Please check your internet and try again.';
    }
    return 'Could not fetch data. Please try again.';
  }

  String _actionErrorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final responseData = error.response?.data;
      final responseMessage = responseData is Map<String, dynamic>
          ? responseData['message']?.toString()
          : null;
      if (status == 403) {
        final lowered = responseMessage?.toLowerCase() ?? '';
        if (lowered.contains('artist') ||
            lowered.contains('album') ||
            lowered.contains('forbidden')) {
          return 'Only artists can create albums';
        }
      }
      if (status == 400 && responseMessage != null && responseMessage.isNotEmpty) {
        if (responseMessage.toLowerCase().contains('cannot convert to album') ||
            responseMessage.toLowerCase().contains('do not belong to you')) {
          return responseMessage;
        }
      }
      final failure = NetworkExceptions.fromDioException(error);
      if (failure is ValidationFailure ||
          failure is UnauthorizedFailure ||
          failure is ForbiddenFailure ||
          failure is ConflictFailure) {
        return 'Action not permissible.';
      }
      if (failure is NetworkFailure || failure is ServerFailure) {
        return 'Could not fetch data. Please check your internet and try again.';
      }
    }
    final lowered = error.toString().toLowerCase();
    if (lowered.contains('bad request') ||
        lowered.contains('forbidden') ||
        lowered.contains('unauthorized') ||
        lowered.contains('not allowed')) {
      return 'Action not permissible.';
    }
    return 'Could not fetch data. Please try again.';
  }

  String _currentUserRole() {
    final profileRole = ref.read(profileProvider).profile?.role.toUpperCase();
    final authRole = ref.read(authControllerProvider).value?.role.toUpperCase();
    return (profileRole ?? authRole ?? 'USER').toUpperCase();
  }

  String? _currentUserId() {
    final profileId = ref.read(profileProvider).profile?.id.trim();
    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }
    final authId = ref.read(authControllerProvider).value?.id.trim();
    if (authId != null && authId.isNotEmpty) {
      return authId;
    }
    return null;
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

  PlaylistEntity _withIsLiked(PlaylistEntity p, bool isLiked) => p.copyWith(
    isLiked: isLiked,
    likeCount: isLiked ? p.likeCount + 1 : (p.likeCount - 1).clamp(0, 999999),
  );

  Future<int> _getPlaylistLimit() async {
    try {
      final subscription = ref
          .read(subscriptionNotifierProvider)
          .currentSubscription;
      final playlistLimit = subscription.features.playlistLimit;
      return playlistLimit == -1 ? -1 : playlistLimit > 0 ? playlistLimit : 3;
    } catch (_) {
      return 3;
    }
  }
}
