import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/profile/presentation/widgets/discard_dialog.dart';
import '../../../../shared/ui/widgets/edit_screen_app_bar.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_track_entity.dart';
import '../providers/playlist_providers.dart';
import '../widgets/playlist_form_fields.dart';

class PlaylistEditScreen extends ConsumerStatefulWidget {
  const PlaylistEditScreen({super.key, required this.collectionId});
  final String collectionId;

  @override
  ConsumerState<PlaylistEditScreen> createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends ConsumerState<PlaylistEditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  List<PlaylistTrackEntity> _tracks = [];
  CollectionPrivacy _privacy = CollectionPrivacy.public;
  bool _tracksDirty = false;
  bool _detailsDirty = false;
  bool _initialized = false;
  final _tracksTabKey = GlobalKey<_TracksTabState>();

  bool get _dirty => _tracksDirty || _detailsDirty;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    Future.microtask(_loadIfNeeded);
  }

  Future<void> _loadIfNeeded() async {
    final s = ref.read(playlistNotifierProvider);
    if (s.activePlaylist?.id == widget.collectionId && s.activeTracks.isNotEmpty) {
      _initFromState(s);
    } else {
      await ref
          .read(playlistNotifierProvider.notifier)
          .openPlaylist(widget.collectionId);
      if (mounted) _initFromState(ref.read(playlistNotifierProvider));
    }
  }

  void _initFromState(dynamic s) {
    setState(() {
      _tracks = List.of(s.activeTracks as List<PlaylistTrackEntity>);
      _titleCtrl.text = s.activePlaylist?.title ?? '';
      _descCtrl.text = s.activePlaylist?.description ?? '';
      _privacy = s.activePlaylist?.privacy ?? CollectionPrivacy.public;
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryClose() async {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }
    final discard = await showDiscardDialog(context);
    if (discard == true && mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1C1C1E),
          content: Text(
            'Title is required',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final notifier = ref.read(playlistNotifierProvider.notifier);

    if (_detailsDirty) {
      await notifier.editCollection(
        id: widget.collectionId,
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        privacy: _privacy,
      );
    }

    if (_tracksDirty) {
      final finalOrder = _tracksTabKey.currentState?._tracks ?? _tracks;
      await notifier.reorderTracks(
        collectionId: widget.collectionId,
        trackIds: finalOrder.map((t) => t.trackId).toList(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = ref.watch(
      playlistNotifierProvider.select((s) => s.isMutating),
    );
    final isLoading = ref.watch(
      playlistNotifierProvider.select((s) => s.isDetailLoading),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: editScreenAppBar(
        title: 'Edit',
        onClose: _tryClose,
        onSave: _save,
        isBusy: isMutating || (isLoading && !_initialized),
        saveEnabled: _initialized,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tracks'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: !_initialized
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _TracksTab(
                  key: _tracksTabKey,
                  initialTracks: _tracks,
                  onReordered: () => setState(() => _tracksDirty = true),
                ),
                _buildDetailsTab(),
              ],
            ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlaylistTitleField(
            controller: _titleCtrl,
            onChanged: () => setState(() => _detailsDirty = true),
          ),
          const SizedBox(height: 12),
          PlaylistDescriptionField(
            controller: _descCtrl,
            onChanged: () => setState(() => _detailsDirty = true),
          ),
          const SizedBox(height: 20),
          PlaylistPrivacyToggle(
            value: _privacy,
            onChanged: (v) => setState(() {
              _privacy = v;
              _detailsDirty = true;
            }),
          ),
        ],
      ),
    );
  }
}

class _TracksTab extends StatefulWidget {
  const _TracksTab({
    super.key,
    required this.initialTracks,
    required this.onReordered,
  });

  final List<PlaylistTrackEntity> initialTracks;
  final VoidCallback onReordered;

  @override
  State<_TracksTab> createState() => _TracksTabState();
}

class _TracksTabState extends State<_TracksTab> {
  late List<PlaylistTrackEntity> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.of(widget.initialTracks);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _tracks.removeAt(oldIndex);
      _tracks.insert(newIndex, item);
    });
    widget.onReordered();
  }

  @override
  Widget build(BuildContext context) {
    if (_tracks.isEmpty) {
      return const Center(
        child: Text('No tracks yet', style: TextStyle(color: Colors.white38)),
      );
    }

    return ReorderableListView.builder(
      itemCount: _tracks.length,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) => Material(
        color: const Color(0xFF1A1A1A),
        child: child,
      ),
      itemBuilder: (_, i) {
        final t = _tracks[i];
        return ListTile(
          key: ValueKey(t.trackId),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: t.coverUrl != null
                ? Image.network(t.coverUrl!, fit: BoxFit.cover)
                : const Icon(Icons.music_note, color: Colors.white38, size: 22),
          ),
          title: Text(
            t.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            t.ownerDisplayName ?? t.ownerUsername,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: ReorderableDragStartListener(
            index: i,
            child: const Icon(Icons.drag_handle, color: Colors.white38),
          ),
        );
      },
    );
  }
}
