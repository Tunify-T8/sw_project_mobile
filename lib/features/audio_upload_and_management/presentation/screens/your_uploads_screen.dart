import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import 'track_metadata_screen.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/library_uploads_state.dart';
import '../widgets/artist_tool_paywall_sheet.dart';
import '../widgets/artist_tools_banner.dart';
import '../widgets/artist_tools_sheet.dart';
import '../widgets/uploads_search_header.dart';
import '../utils/upload_auth_guard.dart';
import 'track_detail_screen.dart';
import 'edit_track_screen.dart';

class YourUploadsScreen extends ConsumerStatefulWidget {
  const YourUploadsScreen({
    super.key,
    this.onStartUpload,
    this.onOpenSubscription,
  });

  final VoidCallback? onStartUpload;
  final VoidCallback? onOpenSubscription;

  @override
  ConsumerState<YourUploadsScreen> createState() => _YourUploadsScreenState();
}

class _YourUploadsScreenState extends ConsumerState<YourUploadsScreen> {
  late final TextEditingController _searchCtrl;
  Future<void> _startInlineUpload() async {
    final canUpload = await ensureUploadAuthenticated(context, ref);
    if (!canUpload) return;

    final userId = ref.read(currentUploadUserIdProvider);
    final track = await ref
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload(userId);

    if (!mounted || track == null) return;

    final audioName =
        ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file';

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            TrackMetadataScreen(trackId: track.trackId, fileName: audioName),
      ),
    );

    if (result == true && mounted) {
      await ref.read(libraryUploadsProvider.notifier).refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    // Always start with a fresh load — no seed data
    Future.microtask(() => ref.read(libraryUploadsProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LibraryUploadsState>(libraryUploadsProvider, (_, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1C1C1E),
            content: Text(next.error!),
          ),
        );
      }
    });

    final state = ref.watch(libraryUploadsProvider);
    final uploadState = ref.watch(uploadProvider);
    final isUploadBusy =
        uploadState.isPreparingUpload || uploadState.isUploading;

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
            // ── Purple gradient header with search + filter ──────────────
            SliverToBoxAdapter(
              child: UploadsSearchHeader(
                controller: _searchCtrl,
                trackCount: state.totalCount,
                onChanged: (v) =>
                    ref.read(libraryUploadsProvider.notifier).setQuery(v),
                onBackTap: () => Navigator.of(context).maybePop(),
                onFilterTap: () => _showFilterSheet(context, state),
              ),
            ),

            // ── Upload / shuffle / play row ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: isUploadBusy ? null : _handleUpload,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isUploadBusy)
                              const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.6,
                                  color: Colors.white,
                                ),
                              ),
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: isUploadBusy
                                  ? Colors.white54
                                  : Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: state.filteredItems.isNotEmpty ? () {} : null,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: state.filteredItems.isNotEmpty
                            ? Colors.white
                            : Colors.white24,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: state.filteredItems.isNotEmpty
                          ? () => _openFirst(state.filteredItems)
                          : null,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: state.filteredItems.isNotEmpty
                              ? Colors.white
                              : const Color(0xFF3A3A3A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: state.filteredItems.isNotEmpty
                              ? Colors.black
                              : Colors.white38,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Artist tools banner ──────────────────────────────────────
            if (state.quota != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: ArtistToolsBanner(
                    onTap: () => showArtistToolsSheet(
                      context: context,
                      quota: state.quota!,
                      onOpenSubscription: widget.onOpenSubscription,
                    ),
                  ),
                ),
              ),

            // ── Loading ──────────────────────────────────────────────────
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            // ── Empty state ──────────────────────────────────────────────
            else if (state.filteredItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onUpload: _handleUpload),
              )
            // ── Track list ───────────────────────────────────────────────
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, index) {
                    final item = state.filteredItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _UploadTile(
                        item: item,
                        isBusy: state.busyTrackId == item.id,
                        onTap: () => _openDetail(item),
                        onDotsPressed: () =>
                            _showOptionsSheet(context, item, state),
                      ),
                    );
                  }, childCount: state.filteredItems.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _handleUpload() {
    if (widget.onStartUpload != null) {
      widget.onStartUpload!();
      return;
    }

    _startInlineUpload();
  }

  void _openFirst(List<UploadItem> items) {
    final first = items.firstWhere(
      (i) => i.isPlayable,
      orElse: () => items.first,
    );
    _openDetail(first);
  }

  void _openDetail(UploadItem item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrackDetailScreen(item: item)));
  }

  void _showOptionsSheet(
    BuildContext context,
    UploadItem item,
    LibraryUploadsState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TrackOptionsSheet(
        item: item,
        onEditTap: () {
          Navigator.pop(context);
          Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (_) => EditTrackScreen(item: item)),
              )
              .then((result) {
                if (result == true) {
                  ref.read(libraryUploadsProvider.notifier).refresh();
                }
              });
        },
        onDeleteTap: () {
          Navigator.pop(context);
          _confirmDelete(context, item);
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UploadItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Delete track?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id);
    }
  }

  void _showFilterSheet(BuildContext context, LibraryUploadsState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterSheet(
        currentSort: state.sortOrder,
        currentVisibility: state.visibilityFilter,
        onSortChanged: (s) =>
            ref.read(libraryUploadsProvider.notifier).setSortOrder(s),
        onVisibilityChanged: (v) =>
            ref.read(libraryUploadsProvider.notifier).setVisibilityFilter(v),
      ),
    );
  }
}

// ── Upload tile matching SoundCloud screenshot ────────────────────────────────

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.item,
    required this.isBusy,
    required this.onTap,
    required this.onDotsPressed,
  });
  final UploadItem item;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onDotsPressed;

  @override
  Widget build(BuildContext context) {
    final hasLocal =
        item.localArtworkPath != null &&
        File(item.localArtworkPath!).existsSync();

    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFF96B7FF),
              child: hasLocal
                  ? Image.file(
                      File(item.localArtworkPath!),
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                    )
                  : const Icon(
                      Icons.account_circle_rounded,
                      color: Color(0xFF4872D7),
                      size: 52,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Title + artist + duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.status == UploadProcessingStatus.processing)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROCESSING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.artistDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  item.durationLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          // 3 dots
          if (isBusy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            GestureDetector(
              onTap: onDotsPressed,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.more_horiz, color: Colors.white54, size: 24),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUpload});
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'No uploads yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your uploads will show up here.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onUpload,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload a track',
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white54,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3-dot options sheet matching SoundCloud screenshot ────────────────────────

class _TrackOptionsSheet extends StatelessWidget {
  const _TrackOptionsSheet({
    required this.item,
    required this.onEditTap,
    required this.onDeleteTap,
  });
  final UploadItem item;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final hasLocal =
        item.localArtworkPath != null &&
        File(item.localArtworkPath!).existsSync();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header with artwork + title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: const Color(0xFF3A4A6A),
                      child: hasLocal
                          ? Image.file(
                              File(item.localArtworkPath!),
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.account_circle_rounded,
                              color: Color(0xFF4872D7),
                              size: 44,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.artistDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Share row
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SHARE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _ShareBtn(icon: Icons.send_outlined, label: 'Message'),
                  _ShareBtn(icon: Icons.copy_outlined, label: 'Copy link'),
                  _ShareBtn(icon: Icons.qr_code_2, label: 'QR code'),
                  _ShareBtn(icon: Icons.sms_outlined, label: 'SMS'),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _OptionRow(
              icon: Icons.favorite_border,
              label: 'Like',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.edit_outlined,
              label: 'Edit track',
              onTap: onEditTap,
            ),
            const Divider(color: Colors.white12, height: 1),
            _OptionRow(
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.playlist_play,
              label: 'Play last',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.playlist_add,
              label: 'Add to playlist',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.radio,
              label: 'Start station',
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: Colors.white12, height: 1),
            _OptionRow(
              icon: Icons.graphic_eq,
              label: 'Behind this track',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.comment_outlined,
              label: 'View comments',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareBtn extends StatelessWidget {
  const _ShareBtn({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      dense: true,
    );
  }
}

// ── Filter sheet matching SoundCloud screenshot ───────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.currentSort,
    required this.currentVisibility,
    required this.onSortChanged,
    required this.onVisibilityChanged,
  });
  final UploadSortOrder currentSort;
  final UploadVisibilityFilter currentVisibility;
  final ValueChanged<UploadSortOrder> onSortChanged;
  final ValueChanged<UploadVisibilityFilter> onVisibilityChanged;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late UploadSortOrder _sort;
  late UploadVisibilityFilter _visibility;

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
    _visibility = widget.currentVisibility;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              _filterRow('Recently added', UploadSortOrder.recentlyAdded, null),
              _filterRow('First added', UploadSortOrder.firstAdded, null),
              _filterRow('Track name', UploadSortOrder.trackName, null),
              const Divider(color: Colors.white12, height: 1),
              _visibilityRow('All', UploadVisibilityFilter.all),
              _visibilityRow('Public', UploadVisibilityFilter.public),
              _visibilityRow('Private', UploadVisibilityFilter.private),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterRow(String label, UploadSortOrder sort, dynamic _) {
    final selected = _sort == sort;
    return ListTile(
      onTap: () {
        setState(() => _sort = sort);
        widget.onSortChanged(sort);
      },
      leading: Icon(
        Icons.check,
        color: selected ? Colors.white : Colors.transparent,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      dense: true,
    );
  }

  Widget _visibilityRow(String label, UploadVisibilityFilter filter) {
    final selected = _visibility == filter;
    return ListTile(
      onTap: () {
        setState(() => _visibility = filter);
        widget.onVisibilityChanged(filter);
      },
      leading: Icon(
        Icons.check,
        color: selected ? Colors.white : Colors.transparent,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      dense: true,
    );
  }
}
