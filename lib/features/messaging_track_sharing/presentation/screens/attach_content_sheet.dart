import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message_attachment.dart';

/// Bottom sheet with four tabs (Likes · Playlists · Albums · Uploads) that
/// lets the user pick content to attach to a message.
///
/// Returns a `List<MessageAttachment>` when the user taps **Done**, or
/// `null` if cancelled.
class AttachContentSheet extends ConsumerStatefulWidget {
  const AttachContentSheet({super.key});

  @override
  ConsumerState<AttachContentSheet> createState() =>
      _AttachContentSheetState();
}

class _AttachContentSheetState extends ConsumerState<AttachContentSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<MessageAttachment> _selected = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggle(MessageAttachment item) {
    setState(() {
      final existing = _selected.where((s) => s.id == item.id);
      if (existing.isNotEmpty) {
        _selected.removeAll(existing.toList());
      } else {
        _selected.add(item);
      }
    });
  }

  bool _isSelected(String id) => _selected.any((s) => s.id == id);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // ── Header: Cancel / Title / Done ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Attach content',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, _selected.toList()),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),

          // ── Tabs ─────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF8A8A8A),
            labelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Likes'),
              Tab(text: 'Playlists'),
              Tab(text: 'Albums'),
              Tab(text: 'Uploads'),
            ],
          ),

          // ── Tab bodies ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LikesTab(
                  isSelected: _isSelected,
                  onToggle: _toggle,
                ),
                _PlaylistsTab(
                  isSelected: _isSelected,
                  onToggle: _toggle,
                ),
                const _EmptyTab(label: 'No albums yet'),
                _UploadsTab(
                  isSelected: _isSelected,
                  onToggle: _toggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Likes tab ────────────────────────────────────────────────────────────────

class _LikesTab extends ConsumerWidget {
  const _LikesTab({
    required this.isSelected,
    required this.onToggle,
  });

  final bool Function(String id) isSelected;
  final ValueChanged<MessageAttachment> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user's id to fetch their liked tracks.
    final viewerId =
        ref.watch(authControllerProvider).value?.id ?? 'user_current_1';
    final usecase = ref.read(getLikedTracksUsecaseProvider);

    return FutureBuilder(
      future: usecase.call(viewerId: viewerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) {
          return const _EmptyTab(label: 'No liked tracks yet');
        }
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final attachment = MessageAttachment(
              id: track.trackId,
              type: MessageAttachmentType.track,
              title: track.title,
              artworkUrl: track.coverUrl,
            );
            return _ContentTile(
              title: track.title,
              subtitle: track.artistName,
              imageUrl: track.coverUrl,
              selected: isSelected(track.trackId),
              onTap: () => onToggle(attachment),
            );
          },
        );
      },
    );
  }
}

// ── Playlists tab (mock data — no playlist provider exists yet) ──────────────

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab({
    required this.isSelected,
    required this.onToggle,
  });

  final bool Function(String id) isSelected;
  final ValueChanged<MessageAttachment> onToggle;

  // Hard-coded mock playlists matching the screenshots.
  static const _playlists = [
    _MockPlaylist(id: 'pl_1', title: 'test1', owner: 'Rozana Ahmed'),
    _MockPlaylist(
        id: 'pl_2', title: 'Untitled playlist', owner: 'Rozana Ahmed'),
    _MockPlaylist(
        id: 'pl_3', title: 'Pop Fit Workout', owner: 'Discovery Playlists'),
    _MockPlaylist(id: 'pl_4', title: 'Rand', owner: 'Rozana Ahmed'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final pl = _playlists[index];
        final attachment = MessageAttachment(
          id: pl.id,
          type: MessageAttachmentType.collection,
          title: pl.title,
        );
        return _ContentTile(
          title: pl.title,
          subtitle: pl.owner,
          selected: isSelected(pl.id),
          onTap: () => onToggle(attachment),
        );
      },
    );
  }
}

class _MockPlaylist {
  const _MockPlaylist({
    required this.id,
    required this.title,
    required this.owner,
  });
  final String id;
  final String title;
  final String owner;
}

// ── Uploads tab ──────────────────────────────────────────────────────────────

class _UploadsTab extends ConsumerWidget {
  const _UploadsTab({
    required this.isSelected,
    required this.onToggle,
  });

  final bool Function(String id) isSelected;
  final ValueChanged<MessageAttachment> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadsState = ref.watch(libraryUploadsProvider);
    final items = uploadsState.items;

    if (uploadsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (items.isEmpty) {
      return const _EmptyTab(label: 'No uploads yet');
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final attachment = MessageAttachment(
          id: item.id,
          type: MessageAttachmentType.track,
          title: item.title,
          artworkUrl: item.artworkUrl,
        );
        return _ContentTile(
          title: item.title,
          subtitle: item.artistDisplay,
          imageUrl: item.artworkUrl,
          selected: isSelected(item.id),
          onTap: () => onToggle(attachment),
        );
      },
    );
  }
}

// ── Shared content tile (avatar / title / subtitle / radio circle) ───────────

class _ContentTile extends StatelessWidget {
  const _ContentTile({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF8A8A8A),
          fontSize: 13,
        ),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFF5A5A5A),
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }

  static Widget _placeholder() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.person, color: Color(0xFF5A5A5A), size: 28),
      );
}

// ── Empty tab placeholder ────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.white38, fontSize: 15),
      ),
    );
  }
}
