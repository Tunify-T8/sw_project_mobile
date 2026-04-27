import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import '../../../feed_search_discovery/domain/entities/track_result_entity.dart';
import '../../../feed_search_discovery/presentation/providers/search_provider.dart';
import '../providers/playlist_providers.dart';

void showAddTrackSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String collectionId,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddTrackSheet(outerRef: ref, collectionId: collectionId),
  );
}

class _AddTrackSheet extends ConsumerStatefulWidget {
  const _AddTrackSheet({required this.outerRef, required this.collectionId});

  final WidgetRef outerRef;
  final String collectionId;

  @override
  ConsumerState<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends ConsumerState<_AddTrackSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _addingTrackId;

  List<TrackResultEntity>? _searchResults;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(libraryUploadsProvider);
      if (state.items.isEmpty && !state.isLoading) {
        ref.read(libraryUploadsProvider.notifier).load();
      }
    });
    _searchCtrl.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final q = _searchCtrl.text.trim();
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _searchResults = null;
        _isSearching = false;
      }
    });
    _debounce?.cancel();
    if (q.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final results =
          await ref.read(searchTracksUseCaseProvider).call(q, page: 1, limit: 30);
      if (mounted && _query == q) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFromLibrary(UploadItem track) async {
    setState(() => _addingTrackId = track.id);
    await widget.outerRef.read(playlistNotifierProvider.notifier).addTrack(
          collectionId: widget.collectionId,
          trackId: track.id,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addFromSearch(TrackResultEntity track) async {
    setState(() => _addingTrackId = track.id);
    await widget.outerRef.read(playlistNotifierProvider.notifier).addTrack(
          collectionId: widget.collectionId,
          trackId: track.id,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final uploadsState = ref.watch(libraryUploadsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    Widget body;
    if (_query.isEmpty) {
      // ── Library mode ────────────────────────────────────────────────────
      final tracks = uploadsState.items;
      if (uploadsState.isLoading && tracks.isEmpty) {
        body = const Center(
            child: CircularProgressIndicator(color: Colors.white));
      } else if (uploadsState.error != null && tracks.isEmpty) {
        body = Center(
          child: Text(uploadsState.error!,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center),
        );
      } else if (tracks.isEmpty) {
        body = const Center(
          child: Text('No uploads yet',
              style: TextStyle(color: Colors.white38)),
        );
      } else {
        body = ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (_, i) => _TrackRow(
            title: tracks[i].title,
            subtitle: tracks[i].artistDisplay,
            duration: tracks[i].durationLabel,
            coverUrl: tracks[i].artworkUrl,
            isAdding: _addingTrackId == tracks[i].id,
            onTap: () => _addFromLibrary(tracks[i]),
          ),
        );
      }
    } else {
      // ── Search mode ─────────────────────────────────────────────────────
      if (_isSearching) {
        body = const Center(
            child: CircularProgressIndicator(color: Colors.white));
      } else if (_searchResults == null || _searchResults!.isEmpty) {
        body = Center(
          child: Text('No results for "$_query"',
              style: const TextStyle(color: Colors.white38)),
        );
      } else {
        body = ListView.builder(
          itemCount: _searchResults!.length,
          itemBuilder: (_, i) {
            final t = _searchResults![i];
            final mins = t.durationSeconds ~/ 60;
            final secs = (t.durationSeconds % 60).toString().padLeft(2, '0');
            return _TrackRow(
              title: t.title,
              subtitle: t.artistName,
              duration: '$mins:$secs',
              coverUrl: t.artworkUrl,
              isAdding: _addingTrackId == t.id,
              onTap: () => _addFromSearch(t),
            );
          },
        );
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      height: MediaQuery.of(context).size.height * 0.75,
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a track',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tracks',
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
          Expanded(child: body),
          SizedBox(height: bottom + 8),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.coverUrl,
    required this.isAdding,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String? coverUrl;
  final bool isAdding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isAdding ? null : onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: coverUrl != null
            ? Image.network(coverUrl!, fit: BoxFit.cover)
            : const Icon(Icons.music_note, color: Colors.white38, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$subtitle · $duration',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isAdding
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white54),
            )
          : const Icon(Icons.add, color: Colors.white54, size: 22),
    );
  }
}
