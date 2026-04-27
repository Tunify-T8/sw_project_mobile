import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../providers/playlist_providers.dart';
import 'create_edit_playlist_sheet.dart';

Future<void> showSelectPlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String trackId,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  return navigator.push(
    PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) =>
          _SelectPlaylistScreen(outerRef: ref, trackId: trackId),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (_, animation, __, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        );
      },
    ),
  );
}

class _SelectPlaylistScreen extends ConsumerStatefulWidget {
  const _SelectPlaylistScreen({
    required this.outerRef,
    required this.trackId,
  });

  final WidgetRef outerRef;
  final String trackId;

  @override
  ConsumerState<_SelectPlaylistScreen> createState() =>
      _SelectPlaylistScreenState();
}

class _SelectPlaylistScreenState extends ConsumerState<_SelectPlaylistScreen> {
  static const int _membershipPageSize = 50;

  final Set<String> _mutatingIds = {};
  final Set<String> _addedIds = {};
  final Set<String> _resolvingCoverIds = {};
  final Map<String, String> _resolvedCoverUrls = {};
  final Map<String, int> _trackCountOverrides = {};
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isResolvingSelections = false;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
    Future.microtask(() async {
      final notifier = ref.read(playlistNotifierProvider.notifier);
      final state = ref.read(playlistNotifierProvider);
      if (state.myCollections.isEmpty && !state.isMyCollectionsLoading) {
        await notifier.loadMyCollections();
      }
      if (!mounted) return;
      await _resolveMissingCovers(ref.read(playlistNotifierProvider).myCollections);
      if (!mounted) return;
      await _resolveExistingSelections(
        ref.read(playlistNotifierProvider).myCollections,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveMissingCovers(
    List<PlaylistSummaryEntity> playlists,
  ) async {
    final repo = ref.read(playlistRepositoryProvider);
    final pending = playlists.where((playlist) {
      return playlist.type == CollectionType.playlist &&
          playlist.trackCount > 0 &&
          (playlist.coverUrl == null || playlist.coverUrl!.isEmpty) &&
          !_resolvedCoverUrls.containsKey(playlist.id) &&
          !_resolvingCoverIds.contains(playlist.id);
    }).toList();

    for (final playlist in pending) {
      _resolvingCoverIds.add(playlist.id);
      try {
        final tracks = await repo.getCollectionTracks(
          collectionId: playlist.id,
          limit: 1,
        );
        final coverUrl =
            tracks.items.isNotEmpty ? tracks.items.first.coverUrl : null;
        if (!mounted) return;
        if (coverUrl != null && coverUrl.isNotEmpty) {
          setState(() => _resolvedCoverUrls[playlist.id] = coverUrl);
        }
      } catch (_) {
        // Ignore cover fallback failures and keep the placeholder.
      } finally {
        _resolvingCoverIds.remove(playlist.id);
      }
    }
  }

  Future<void> _resolveExistingSelections(
    List<PlaylistSummaryEntity> playlists,
  ) async {
    if (_isResolvingSelections) return;
    _isResolvingSelections = true;

    try {
      final candidateIds = playlists
          .where((playlist) => playlist.type == CollectionType.playlist)
          .map((playlist) => playlist.id)
          .toSet();
      final existingIds = <String>{};

      for (final playlist in playlists) {
        if (playlist.type != CollectionType.playlist || playlist.trackCount <= 0) {
          continue;
        }

        try {
          if (await _playlistContainsTrack(playlist.id)) {
            existingIds.add(playlist.id);
          }
        } catch (_) {
          // Ignore membership lookup failures and keep the current row state.
        }
      }

      if (!mounted) return;
      setState(() {
        _addedIds.removeWhere(
          (playlistId) =>
              candidateIds.contains(playlistId) &&
              !existingIds.contains(playlistId) &&
              !_mutatingIds.contains(playlistId),
        );
        _addedIds.addAll(existingIds);
      });
    } finally {
      _isResolvingSelections = false;
    }
  }

  Future<bool> _playlistContainsTrack(String playlistId) async {
    final repo = ref.read(playlistRepositoryProvider);
    var page = 1;

    while (true) {
      final tracks = await repo.getCollectionTracks(
        collectionId: playlistId,
        page: page,
        limit: _membershipPageSize,
      );

      if (tracks.items.any((track) => track.trackId == widget.trackId)) {
        return true;
      }

      if (!tracks.hasMore || tracks.items.isEmpty) {
        return false;
      }

      page += 1;
    }
  }

  bool _looksLikeDuplicateAddError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('already in collection') ||
        message.contains('already exists') ||
        message.contains('already added') ||
        message.contains('duplicate');
  }

  PlaylistSummaryEntity _playlistForDisplay(PlaylistSummaryEntity playlist) {
    final resolvedCover = _resolvedCoverUrls[playlist.id];
    final trackCount = _trackCountOverrides[playlist.id] ?? playlist.trackCount;
    if (resolvedCover == null || resolvedCover.isEmpty) {
      if (trackCount == playlist.trackCount) {
        return playlist;
      }
      return PlaylistSummaryEntity(
        id: playlist.id,
        title: playlist.title,
        description: playlist.description,
        type: playlist.type,
        privacy: playlist.privacy,
        coverUrl: playlist.coverUrl,
        trackCount: trackCount,
        likeCount: playlist.likeCount,
        repostsCount: playlist.repostsCount,
        ownerFollowerCount: playlist.ownerFollowerCount,
        isMine: playlist.isMine,
        isLiked: playlist.isLiked,
        createdAt: playlist.createdAt,
        updatedAt: playlist.updatedAt,
      );
    }

    return PlaylistSummaryEntity(
      id: playlist.id,
      title: playlist.title,
      description: playlist.description,
      type: playlist.type,
      privacy: playlist.privacy,
      coverUrl: resolvedCover,
      trackCount: trackCount,
      likeCount: playlist.likeCount,
      repostsCount: playlist.repostsCount,
      ownerFollowerCount: playlist.ownerFollowerCount,
      isMine: playlist.isMine,
      isLiked: playlist.isLiked,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }

  Future<void> _addToPlaylist(PlaylistSummaryEntity playlist) async {
    if (_mutatingIds.contains(playlist.id) || _addedIds.contains(playlist.id)) {
      return;
    }
    setState(() => _mutatingIds.add(playlist.id));
    try {
      await ref.read(addTrackUseCaseProvider).call(
            collectionId: playlist.id,
            trackId: widget.trackId,
          );
      if (!mounted) return;
      setState(() {
        _mutatingIds.remove(playlist.id);
        _addedIds.add(playlist.id);
        _trackCountOverrides[playlist.id] =
            (_trackCountOverrides[playlist.id] ?? playlist.trackCount) + 1;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _mutatingIds.remove(playlist.id);
        if (_looksLikeDuplicateAddError(error)) {
          _addedIds.add(playlist.id);
        }
      });
    }
  }

  Future<void> _removeFromPlaylist(PlaylistSummaryEntity playlist) async {
    if (_mutatingIds.contains(playlist.id) || !_addedIds.contains(playlist.id)) {
      return;
    }
    setState(() => _mutatingIds.add(playlist.id));
    try {
      await ref.read(removeTrackUseCaseProvider).call(
            collectionId: playlist.id,
            trackId: widget.trackId,
          );
      if (!mounted) return;
      setState(() {
        _mutatingIds.remove(playlist.id);
        _addedIds.remove(playlist.id);
        final currentCount =
            _trackCountOverrides[playlist.id] ?? playlist.trackCount;
        _trackCountOverrides[playlist.id] =
            currentCount > 0 ? currentCount - 1 : 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _mutatingIds.remove(playlist.id));
    }
  }

  Future<void> _openCreatePlaylist() async {
    final created = await showCreatePlaylistSheet(
      context: context,
      ref: widget.outerRef,
    );
    if (!mounted) return;
    if (created == null) return;

    await _resolveMissingCovers(ref.read(playlistNotifierProvider).myCollections);
    if (!mounted) return;

    final createdSummary = PlaylistSummaryEntity(
      id: created.id,
      title: created.title,
      description: created.description,
      type: created.type,
      privacy: created.privacy,
      coverUrl: created.coverUrl,
      trackCount: created.trackCount,
      likeCount: created.likeCount,
      repostsCount: created.repostsCount,
      ownerFollowerCount: created.ownerFollowerCount,
      isMine: true,
      isLiked: created.isLiked,
      createdAt: created.createdAt,
      updatedAt: created.updatedAt,
    );

    await _addToPlaylist(createdSummary);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track added to ${created.title}'),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final playlists = state.myCollections
        .where((playlist) => playlist.type == CollectionType.playlist)
        .map(_playlistForDisplay)
        .toList();
    final filtered = _query.isEmpty
        ? playlists
        : playlists
            .where((playlist) => playlist.title.toLowerCase().contains(_query))
            .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resolveMissingCovers(playlists);
        _resolveExistingSelections(playlists);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Add to playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.cast_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: FilledButton(
                      key: const Key('select_playlist_done_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        key: const Key('select_playlist_search_field'),
                        controller: _searchCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: playlists.isEmpty
                              ? 'Search playlists'
                              : 'Search ${playlists.length} playlist${playlists.length == 1 ? '' : 's'}',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white54,
                            size: 24,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.tune,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isMyCollectionsLoading && playlists.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        InkWell(
                          key: const Key('select_playlist_create_button'),
                          onTap: _openCreatePlaylist,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  color: const Color(0xFF707070),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    'Create playlist',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Recently updated',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (filtered.isEmpty && !state.isMyCollectionsLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No playlists yet',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (playlist) => _PlaylistSelectRow(
                              playlist: playlist,
                              isMutating: _mutatingIds.contains(playlist.id),
                              isAdded: _addedIds.contains(playlist.id),
                              onTap: () {
                                if (_addedIds.contains(playlist.id)) {
                                  _removeFromPlaylist(playlist);
                                } else {
                                  _addToPlaylist(playlist);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF242424),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PlaylistSelectRow extends StatelessWidget {
  const _PlaylistSelectRow({
    required this.playlist,
    required this.isMutating,
    required this.isAdded,
    required this.onTap,
  });

  final PlaylistSummaryEntity playlist;
  final bool isMutating;
  final bool isAdded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        'Playlist - ${playlist.trackCount} Track${playlist.trackCount == 1 ? '' : 's'}';

    return InkWell(
      onTap: isMutating ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(2),
              ),
              child: playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty
                  ? Image.network(
                      playlist.coverUrl!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.queue_music,
                      color: Colors.white38,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (playlist.privacy == CollectionPrivacy.private) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.lock,
                          color: Colors.white60,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: isMutating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                    : isAdded
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.white70,
                            size: 28,
                          )
                        : Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 2,
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
