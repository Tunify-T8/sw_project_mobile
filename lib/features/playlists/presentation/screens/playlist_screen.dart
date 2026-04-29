import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/playlist_providers.dart';
import '../widgets/add_track_sheet.dart';
import '../widgets/create_edit_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_share_sheet.dart';
import '../widgets/playlist_tile.dart';


class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  final _searchController = TextEditingController();
  final Map<String, String> _resolvedCoverUrls = {};
  final Set<String> _resolvingCoverIds = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(_reloadPlaylists);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaylistSummaryEntity> _filtered(List<PlaylistSummaryEntity> all) {
    if (_query.isEmpty) return all;
    return all
        .where((p) => p.title.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _reloadPlaylists() async {
    _resolvedCoverUrls.clear();
    _resolvingCoverIds.clear();
    await ref
        .read(playlistNotifierProvider.notifier)
        .loadMyCollections(type: CollectionType.playlist);
  }

  Future<void> _resolvePlaylistCovers(
    List<PlaylistSummaryEntity> playlists,
  ) async {
    final repo = ref.read(playlistRepositoryProvider);
    final pending = playlists.where((playlist) {
      return playlist.type == CollectionType.playlist &&
          playlist.trackCount > 0 &&
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
        final firstTrackCover =
            tracks.items.isNotEmpty ? tracks.items.first.coverUrl : null;
        if (!mounted) return;
        if (firstTrackCover != null && firstTrackCover.isNotEmpty) {
          setState(() => _resolvedCoverUrls[playlist.id] = firstTrackCover);
        }
      } catch (_) {
        // Ignore fallback cover failures and keep the placeholder.
      } finally {
        _resolvingCoverIds.remove(playlist.id);
      }
    }
  }

  PlaylistSummaryEntity _playlistForDisplay(PlaylistSummaryEntity playlist) {
    final resolvedCover = _resolvedCoverUrls[playlist.id];
    if (resolvedCover == null || resolvedCover.isEmpty) {
      return playlist;
    }

    return PlaylistSummaryEntity(
      id: playlist.id,
      title: playlist.title,
      description: playlist.description,
      type: playlist.type,
      privacy: playlist.privacy,
      coverUrl: resolvedCover,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final profile = ref.watch(profileProvider).profile;
    final isArtist = profile?.role.toUpperCase() == 'ARTIST';
    final ownerName = profile?.displayName ?? profile?.userName;
    final playlists = state.myCollections
        .where((p) => p.isMine && p.type == CollectionType.playlist)
        .map(_playlistForDisplay)
        .toList();
    final visible = _filtered(playlists);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resolvePlaylistCovers(state.myCollections);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const MiniPlayer(),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: const Color(0xFF1C1C1E),
        onRefresh: _reloadPlaylists,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── AppBar ──────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.black,
              floating: true,
              title: const Text(
                'Playlists',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cast, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  key: const Key('playlists_add_button'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => showCreatePlaylistSheet(
                    context: context,
                    ref: ref,
                  ),
                ),
              ],
            ),

            // ── Search bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  key: const Key('playlists_search_field'),
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'Search ${playlists.length} playlist${playlists.length != 1 ? 's' : ''}',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: const Icon(Icons.tune, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // ── Import + Create new ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.download_outlined,
                        label: 'Import',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        key: const Key('playlists_create_new_button'),
                        icon: Icons.add,
                        label: 'Create new',
                        onTap: () => showCreatePlaylistSheet(
                          context: context,
                          ref: ref,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── List ────────────────────────────────────────────────────────
            if (state.isMyCollectionsLoading && state.myCollections.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (state.myCollectionsError != null &&
                state.myCollections.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      state.myCollectionsError!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else if (state.myCollections.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.queue_music, color: Colors.white24, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'No playlists yet',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap Create new to get started.',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else if (visible.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No results',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final pl = visible[i];
                  return PlaylistTile(
                    playlist: pl,
                    ownerName: ownerName,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        Routes.playlistDetail,
                        arguments: {'playlistId': pl.id, 'isMine': pl.isMine},
                      );
                      if (!mounted) return;
                      await _reloadPlaylists();
                    },
                    onMoreTap: () => showPlaylistOptionsSheet(
                      context: context,
                      playlist: pl,
                      collectionType: CollectionType.playlist,
                      onShare: () => showPlaylistShareSheet(
                        context: context,
                        playlist: pl,
                      ),
                      onEdit: () async {
                        await Navigator.of(context).pushNamed(
                          Routes.playlistEdit,
                          arguments: {'collectionId': pl.id},
                        );
                        if (!mounted) return;
                        await _reloadPlaylists();
                      },
                      onTogglePrivacy: () {
                        final newPrivacy =
                            pl.privacy == CollectionPrivacy.private
                                ? CollectionPrivacy.public
                                : CollectionPrivacy.private;
                        ref
                            .read(playlistNotifierProvider.notifier)
                            .editCollection(
                              id: pl.id,
                              privacy: newPrivacy,
                            );
                      },
                      onAddMusic: () => showAddTrackSheet(
                        context: context,
                        ref: ref,
                        collectionId: pl.id,
                      ),
                      onDelete: () => ref
                          .read(playlistNotifierProvider.notifier)
                          .deleteCollection(pl.id),
                      onConvertToAlbum: () {
                        if (!isArtist) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Only artists can convert playlists to albums',
                              ),
                            ),
                          );
                          return;
                        }
                        ref
                            .read(playlistNotifierProvider.notifier)
                            .convertToAlbum(pl.id);
                      },
                    ),
                  );
                },
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
