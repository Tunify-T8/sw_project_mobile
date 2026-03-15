import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/library_uploads_state.dart';
import '../widgets/artist_tool_paywall_sheet.dart';
import '../widgets/artist_tools_banner.dart';
import '../widgets/artist_tools_sheet.dart';
import '../widgets/upload_item_tile.dart';
import '../widgets/uploads_empty_state.dart';
import '../widgets/uploads_search_header.dart';

class YourUploadsScreen extends ConsumerStatefulWidget {
  const YourUploadsScreen({
    super.key,
    this.onStartUpload,
    this.onOpenSubscription,
    this.onPlayUpload,
    this.onEditUpload,
    this.onOpenUploadDetails,
  });

  final VoidCallback? onStartUpload;
  final VoidCallback? onOpenSubscription;
  final void Function(UploadItem item)? onPlayUpload;
  final void Function(UploadItem item)? onEditUpload;
  final void Function(UploadItem item)? onOpenUploadDetails;

  @override
  ConsumerState<YourUploadsScreen> createState() => _YourUploadsScreenState();
}

class _YourUploadsScreenState extends ConsumerState<YourUploadsScreen> {
  late final TextEditingController _searchController;

  static const double _bottomReservedHeight = 168;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    Future.microtask(() {
      ref.read(libraryUploadsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LibraryUploadsState>(libraryUploadsProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1C1C1E),
            content: Text(next.error!),
          ),
        );
      }
    });

    final state = ref.watch(libraryUploadsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: const Color(0xFF1C1C1E),
        onRefresh: () => ref.read(libraryUploadsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: UploadsSearchHeader(
                controller: _searchController,
                trackCount: state.filteredItems.length,
                onChanged: (value) {
                  ref.read(libraryUploadsProvider.notifier).setQuery(value);
                },
                onBackTap: () => Navigator.of(context).maybePop(),
                onFilterTap: () => _showNotWired(context, 'Filters'),
              ),
            ),
            SliverToBoxAdapter(
              child: _UploadsTopActionRow(
                hasUploads: state.filteredItems.isNotEmpty,
                onUploadTap: _handleStartUpload,
                onShuffleTap: () => _showNotWired(context, 'Shuffle'),
                onPlayTap: () => _handlePlayFirst(state.filteredItems),
              ),
            ),
            if (state.quota != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: ArtistToolsBanner(
                    onTap: () {
                      showArtistToolsSheet(
                        context: context,
                        quota: state.quota!,
                        onOpenSubscription: widget.onOpenSubscription,
                      );
                    },
                  ),
                ),
              ),
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            else if (state.filteredItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: UploadsEmptyState(
                  onUploadTap: _handleStartUpload,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = state.filteredItems[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: UploadItemTile(
                          item: item,
                          isBusy: state.busyTrackId == item.id,
                          onTap: () => _handleOpenItem(item),
                          onEditTap: () => _handleEdit(item),
                          onDeleteTap: () => _handleDelete(item),
                          onReplaceTap: () => _handleReplace(item, state),
                        ),
                      );
                    },
                    childCount: state.filteredItems.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: _bottomReservedHeight),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStartUpload() {
    if (widget.onStartUpload != null) {
      widget.onStartUpload!.call();
      return;
    }

    _showNotWired(context, 'Upload flow');
  }

  void _handlePlayFirst(List<UploadItem> items) {
    if (items.isEmpty) {
      return;
    }

    final firstPlayable = items.where((item) => item.isPlayable).cast<UploadItem?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (firstPlayable == null) {
      _showNotWired(context, 'No playable upload yet');
      return;
    }

    if (widget.onPlayUpload != null) {
      widget.onPlayUpload!(firstPlayable);
      return;
    }

    _showNotWired(context, 'Player action');
  }

  void _handleOpenItem(UploadItem item) {
    if (widget.onOpenUploadDetails != null) {
      widget.onOpenUploadDetails!(item);
      return;
    }

    if (widget.onPlayUpload != null && item.isPlayable) {
      widget.onPlayUpload!(item);
      return;
    }

    _showNotWired(context, 'Track details');
  }

  void _handleEdit(UploadItem item) {
    if (widget.onEditUpload != null) {
      widget.onEditUpload!(item);
      return;
    }

    _showNotWired(context, 'Edit upload');
  }

  Future<void> _handleDelete(UploadItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: const Text(
            'Delete track?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${item.title}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id);
  }

  Future<void> _handleReplace(
    UploadItem item,
    LibraryUploadsState state,
  ) async {
    final canReplace = state.quota?.canReplaceFiles ?? false;

    if (!canReplace) {
      showArtistToolPaywallSheet(
        context: context,
        kind: ArtistToolKind.replaceFile,
        onSubscribe: widget.onOpenSubscription,
        uploadMinutesRemaining: state.quota?.uploadMinutesRemaining,
        uploadMinutesLimit: state.quota?.uploadMinutesLimit,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'flac', 'm4a'],
    );

    final pickedPath = result?.files.single.path;
    if (pickedPath == null || !mounted) {
      return;
    }

    await ref.read(libraryUploadsProvider.notifier).replaceFile(
          trackId: item.id,
          filePath: pickedPath,
        );
  }

  void _showNotWired(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label is not wired yet.'),
      ),
    );
  }
}

class _UploadsTopActionRow extends StatelessWidget {
  const _UploadsTopActionRow({
    required this.hasUploads,
    required this.onUploadTap,
    required this.onShuffleTap,
    required this.onPlayTap,
  });

  final bool hasUploads;
  final VoidCallback onUploadTap;
  final VoidCallback onShuffleTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    final disabledColor = Colors.white24;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onUploadTap,
            icon: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: hasUploads ? onShuffleTap : null,
            icon: Icon(
              Icons.shuffle_rounded,
              color: hasUploads ? Colors.white : disabledColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: hasUploads ? onPlayTap : null,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: hasUploads ? const Color(0xFFD9D9D9) : const Color(0xFF3A3A3A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: hasUploads ? Colors.black : Colors.white38,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}