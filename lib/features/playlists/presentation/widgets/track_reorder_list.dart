import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playlist_track_entity.dart';
import '../providers/playlist_providers.dart';

/// Full-screen reorder screen.
/// Push with:
///   Navigator.of(context).pushNamed(
///     Routes.playlistReorder,
///     arguments: {'collectionId': id},
///   );
class TrackReorderScreen extends ConsumerStatefulWidget {
  const TrackReorderScreen({super.key, required this.collectionId});
  final String collectionId;

  @override
  ConsumerState<TrackReorderScreen> createState() => _TrackReorderScreenState();
}

class _TrackReorderScreenState extends ConsumerState<TrackReorderScreen> {
  late List<PlaylistTrackEntity> _tracks;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _tracks = List.of(ref.read(playlistNotifierProvider).activeTracks);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _tracks.removeAt(oldIndex);
      _tracks.insert(newIndex, item);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }
    await ref.read(playlistNotifierProvider.notifier).reorderTracks(
          collectionId: widget.collectionId,
          trackIds: _tracks.map((t) => t.trackId).toList(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = ref.watch(
      playlistNotifierProvider.select((s) => s.isMutating),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reorder tracks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: isMutating ? null : _save,
            child: isMutating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  )
                : const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _tracks.length,
        onReorder: _onReorder,
        proxyDecorator: (child, _, animation) => Material(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(4),
          child: child,
        ),
        itemBuilder: (_, i) {
          final track = _tracks[i];
          return _ReorderRow(key: ValueKey(track.trackId), track: track);
        },
      ),
    );
  }
}

// ─── Row ──────────────────────────────────────────────────────────────────────

class _ReorderRow extends StatelessWidget {
  const _ReorderRow({super.key, required this.track});
  final PlaylistTrackEntity track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: track.coverUrl != null
            ? Image.network(track.coverUrl!, fit: BoxFit.cover)
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
        track.ownerDisplayName ?? track.ownerUsername,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.drag_handle,
        color: Colors.white38,
      ),
    );
  }
}
