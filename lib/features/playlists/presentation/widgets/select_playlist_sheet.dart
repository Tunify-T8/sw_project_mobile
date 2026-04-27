import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../providers/playlist_providers.dart';
import 'create_edit_playlist_sheet.dart';

void showSelectPlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String trackId,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _SelectPlaylistSheet(outerRef: ref, trackId: trackId),
  );
}

class _SelectPlaylistSheet extends ConsumerStatefulWidget {
  const _SelectPlaylistSheet({
    required this.outerRef,
    required this.trackId,
  });

  final WidgetRef outerRef;
  final String trackId;

  @override
  ConsumerState<_SelectPlaylistSheet> createState() =>
      _SelectPlaylistSheetState();
}

class _SelectPlaylistSheetState extends ConsumerState<_SelectPlaylistSheet> {
  final Set<String> _addingIds = {};
  final Set<String> _addedIds = {};
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
    Future.microtask(() {
      final state = ref.read(playlistNotifierProvider);
      if (state.myCollections.isEmpty && !state.isMyCollectionsLoading) {
        ref.read(playlistNotifierProvider.notifier).loadMyCollections();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToPlaylist(PlaylistSummaryEntity playlist) async {
    if (_addingIds.contains(playlist.id) || _addedIds.contains(playlist.id)) {
      return;
    }
    setState(() => _addingIds.add(playlist.id));
    try {
      await ref.read(addTrackUseCaseProvider).call(
            collectionId: playlist.id,
            trackId: widget.trackId,
          );
      if (mounted) {
        setState(() {
          _addingIds.remove(playlist.id);
          _addedIds.add(playlist.id);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _addingIds.remove(playlist.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final all = state.myCollections;
    final filtered = _query.isEmpty
        ? all
        : all.where((p) => p.title.toLowerCase().contains(_query)).toList();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add to playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: all.isEmpty
                    ? 'Search playlists'
                    : 'Search ${all.length} playlist${all.length == 1 ? '' : 's'}',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
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
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: state.isMyCollectionsLoading && all.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : ListView(
                    padding: EdgeInsets.only(bottom: bottom + 8),
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          showCreatePlaylistSheet(
                            context: context,
                            ref: widget.outerRef,
                          );
                        },
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white70, size: 24),
                        ),
                        title: const Text(
                          'Create playlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (filtered.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text(
                            'Recently updated',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                        ...filtered.map(
                          (p) => _PlaylistSelectRow(
                            playlist: p,
                            isAdding: _addingIds.contains(p.id),
                            isAdded: _addedIds.contains(p.id),
                            onTap: () => _addToPlaylist(p),
                          ),
                        ),
                      ] else if (!state.isMyCollectionsLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No playlists yet',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistSelectRow extends StatelessWidget {
  const _PlaylistSelectRow({
    required this.playlist,
    required this.isAdding,
    required this.isAdded,
    required this.onTap,
  });

  final PlaylistSummaryEntity playlist;
  final bool isAdding;
  final bool isAdded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (isAdding || isAdded) ? null : onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: playlist.coverUrl != null
            ? Image.network(playlist.coverUrl!, fit: BoxFit.cover)
            : const Icon(Icons.queue_music, color: Colors.white38, size: 22),
      ),
      title: Text(
        playlist.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            '${playlist.type.name[0].toUpperCase()}${playlist.type.name.substring(1)}'
            ' · ${playlist.trackCount} Track${playlist.trackCount != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (playlist.privacy == CollectionPrivacy.private) ...[
            const SizedBox(width: 4),
            const Icon(Icons.lock, color: Colors.white38, size: 12),
          ],
        ],
      ),
      trailing: isAdding
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white54),
            )
          : isAdded
              ? const Icon(Icons.check_circle,
                  color: Color(0xFFFF5500), size: 24)
              : Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 2),
                  ),
                ),
    );
  }
}
