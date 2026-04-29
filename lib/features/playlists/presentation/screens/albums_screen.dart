import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/playlist_providers.dart';
import '../widgets/create_edit_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_share_sheet.dart';
import '../widgets/playlist_tile.dart';

class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(playlistNotifierProvider.notifier)
          .loadMyCollections(type: CollectionType.album),
    );
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
    return all.where((p) => p.title.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final profile = ref.watch(profileProvider).profile;
    final profileRole = profile?.role.toUpperCase();
    final authRole = ref.watch(authControllerProvider).value?.role.toUpperCase();
    final role = (profileRole ?? authRole ?? 'USER').toUpperCase();
    final isListener = role != 'ARTIST';
    final ownerName = profile?.displayName ?? profile?.userName;
    final albums = state.myCollections
        .where((p) => p.isMine && p.type == CollectionType.album)
        .toList();
    final visible = _filtered(albums);

    return Scaffold(
      key: const Key('albums_screen'),
      backgroundColor: Colors.black,
      bottomNavigationBar: const MiniPlayer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
            title: const Text('Albums', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                key: const Key('albums_add_button'),
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => showCreatePlaylistSheet(
                  context: context,
                  ref: ref,
                  type: CollectionType.album,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                key: const Key('albums_search_field'),
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search ${albums.length} albums',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (state.isMyCollectionsLoading && albums.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  key: Key('albums_loading_indicator'),
                  color: Colors.white,
                ),
              ),
            )
          else if (visible.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No albums yet',
                  key: Key('albums_empty_state'),
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: visible.length,
              itemBuilder: (_, i) {
                final album = visible[i];
                return PlaylistTile(
                  key: ValueKey('album_tile_${album.id}'),
                  playlist: album,
                  ownerName: ownerName,
                  showReleaseDate: true,
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.playlistDetail,
                    arguments: {'playlistId': album.id, 'isMine': album.isMine},
                  ),
                  onMoreTap: () => showPlaylistOptionsSheet(
                    context: context,
                    playlist: album,
                    collectionType: CollectionType.album,
                    useAlbumListenerLayout: isListener,
                    onShare: () => showPlaylistShareSheet(
                      context: context,
                      playlist: album,
                    ),
                    onTogglePrivacy: isListener ? null : () {
                      final newPrivacy = album.privacy == CollectionPrivacy.private
                          ? CollectionPrivacy.public
                          : CollectionPrivacy.private;
                      ref.read(playlistNotifierProvider.notifier).editCollection(
                            id: album.id,
                            privacy: newPrivacy,
                          );
                    },
                    onDelete: isListener ? null : () => ref
                        .read(playlistNotifierProvider.notifier)
                        .deleteCollection(album.id),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }
}
