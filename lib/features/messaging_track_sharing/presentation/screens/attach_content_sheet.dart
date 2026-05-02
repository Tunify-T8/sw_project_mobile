import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../playlists/domain/entities/collection_type.dart';
import '../../../playlists/presentation/providers/playlist_providers.dart';
import '../../domain/entities/message_attachment.dart';

/// Bottom sheet for choosing content to attach to a message.
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
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() async {
      final uploadsState = ref.read(libraryUploadsProvider);
      if (!uploadsState.isLoading && uploadsState.items.isEmpty) {
        await ref.read(libraryUploadsProvider.notifier).load();
      }

      final playlistState = ref.read(playlistNotifierProvider);
      if (!playlistState.isMyCollectionsLoading &&
          playlistState.myCollections.isEmpty) {
        await ref
            .read(playlistNotifierProvider.notifier)
            .loadMyCollections(type: CollectionType.playlist, limit: 100);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggle(MessageAttachment item) {
    setState(() {
      final existing = _selected.where((s) => s.id == item.id).toList();
      if (existing.isNotEmpty) {
        _selected.removeAll(existing);
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
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
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
                  onPressed: () => Navigator.pop(context, _selected.toList()),
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
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF8A8A8A),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Likes'),
              Tab(text: 'Playlists'),
              Tab(text: 'Uploads'),
            ],
          ),
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

class _LikesTab extends ConsumerWidget {
  const _LikesTab({
    required this.isSelected,
    required this.onToggle,
  });

  final bool Function(String id) isSelected;
  final ValueChanged<MessageAttachment> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              backendKind: MessageAttachmentBackendKind.trackLike,
              title: track.title,
              subtitle: track.artistName,
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

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab({
    required this.isSelected,
    required this.onToggle,
  });

  final bool Function(String id) isSelected;
  final ValueChanged<MessageAttachment> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistNotifierProvider);
    final currentUser = ref.watch(authControllerProvider).asData?.value;
    final ownerName = currentUser?.username ?? 'You';
    final playlists = playlistState.myCollections
        .where(
          (playlist) =>
              playlist.type == CollectionType.playlist && playlist.isMine,
        )
        .toList(growable: false);

    if (playlistState.isMyCollectionsLoading && playlists.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (playlistState.myCollectionsError != null && playlists.isEmpty) {
      return _ErrorTab(
        label: 'Could not load playlists',
        onRetry: () => ref
            .read(playlistNotifierProvider.notifier)
            .loadMyCollections(type: CollectionType.playlist, limit: 100),
      );
    }

    if (playlists.isEmpty) {
      return const _EmptyTab(label: 'No playlists yet');
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        final attachment = MessageAttachment(
          id: playlist.id,
          type: MessageAttachmentType.collection,
          backendKind: MessageAttachmentBackendKind.playlist,
          title: playlist.title,
          subtitle: ownerName,
          artworkUrl: playlist.coverUrl,
        );

        return _ContentTile(
          title: playlist.title,
          subtitle: ownerName,
          imageUrl: playlist.coverUrl,
          selected: isSelected(playlist.id),
          onTap: () => onToggle(attachment),
        );
      },
    );
  }
}

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

    final items = uploadsState.filteredItems.isNotEmpty
        ? uploadsState.filteredItems
        : uploadsState.items;

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
          backendKind: MessageAttachmentBackendKind.trackUpload,
          title: item.title,
          subtitle: item.artistDisplay,
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
                errorBuilder: (ctx, err, stack) => _placeholder(),
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
        child: const Icon(
          Icons.music_note,
          color: Color(0xFF5A5A5A),
          size: 26,
        ),
      );
}

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

class _ErrorTab extends StatelessWidget {
  const _ErrorTab({
    required this.label,
    required this.onRetry,
  });

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
