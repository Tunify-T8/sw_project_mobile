import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
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
    builder: (_) => _AddTrackSheet(ref: ref, collectionId: collectionId),
  );
}

class _AddTrackSheet extends ConsumerStatefulWidget {
  const _AddTrackSheet({required this.ref, required this.collectionId});

  final WidgetRef ref;
  final String collectionId;

  @override
  ConsumerState<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends ConsumerState<_AddTrackSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _addingTrackId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(libraryUploadsProvider);
      if (state.items.isEmpty && !state.isLoading) {
        ref.read(libraryUploadsProvider.notifier).load();
      }
    });
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UploadItem> _visible(List<UploadItem> all) {
    if (_query.isEmpty) return all;
    return all
        .where((t) =>
            t.title.toLowerCase().contains(_query) ||
            t.artistDisplay.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _add(UploadItem track) async {
    setState(() => _addingTrackId = track.id);
    await widget.ref.read(playlistNotifierProvider.notifier).addTrack(
          collectionId: widget.collectionId,
          trackId: track.id,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final uploadsState = ref.watch(libraryUploadsProvider);
    final tracks = _visible(uploadsState.items);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // fixed height: ~75% of screen
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 8),
          // drag handle
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
                hintText: 'Search your tracks',
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
            child: uploadsState.isLoading && uploadsState.items.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : uploadsState.error != null && uploadsState.items.isEmpty
                    ? Center(
                        child: Text(
                          uploadsState.error!,
                          style: const TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : tracks.isEmpty
                        ? Center(
                            child: Text(
                              _query.isEmpty
                                  ? 'No uploads yet'
                                  : 'No results for "$_query"',
                              style:
                                  const TextStyle(color: Colors.white38),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tracks.length,
                            itemBuilder: (_, i) => _TrackRow(
                              track: tracks[i],
                              isAdding: _addingTrackId == tracks[i].id,
                              onTap: () => _add(tracks[i]),
                            ),
                          ),
          ),
          SizedBox(height: bottom + 8),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.isAdding,
    required this.onTap,
  });

  final UploadItem track;
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
        child: track.artworkUrl != null
            ? Image.network(track.artworkUrl!, fit: BoxFit.cover)
            : const Icon(Icons.music_note, color: Colors.white38, size: 22),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${track.artistDisplay} · ${track.durationLabel}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isAdding
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            )
          : const Icon(Icons.add, color: Colors.white54, size: 22),
    );
  }
}
