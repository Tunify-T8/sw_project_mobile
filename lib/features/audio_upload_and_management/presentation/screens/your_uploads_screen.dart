// Upload Feature Guide:
// Purpose: Library screen for viewing, filtering, editing, replacing, and deleting the user's uploaded tracks.
// Used by: artist_home_screen, library_screen
// Concerns: Multi-format support; Track visibility.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../domain/entities/upload_item.dart';
import '../controllers/upload_flow_controller.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_error_snackbar.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/artist_tools_banner.dart';
import '../widgets/artist_tools_sheet.dart';
import '../widgets/uploads_search_header.dart';
import '../widgets/your_uploads/your_uploads_action_row.dart';
import '../widgets/your_uploads/your_uploads_dialogs.dart';
import '../widgets/your_uploads/your_uploads_empty_state.dart';
import '../widgets/your_uploads/your_uploads_filter_sheet.dart';
import '../widgets/your_uploads/your_uploads_options_sheet.dart';
import '../widgets/your_uploads/your_uploads_track_tile.dart';
import 'edit_track_screen.dart';

part 'your_uploads_screen_actions.dart';

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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() => loadUploadsLibraryData(ref));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(libraryUploadsProvider, (_, next) {
      if (next.error != null && mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });
    ref.listen(uploadProvider, (_, next) {
      if (next.error != null && mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });

    final state = ref.watch(libraryUploadsProvider);
    final uploadState = ref.watch(uploadProvider);
    final isUploadBusy = uploadState.isBusy;
    final hasVisibleUploads = state.filteredItems.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const MiniPlayer(),
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
                trackCount: state.totalCount,
                onChanged: ref.read(libraryUploadsProvider.notifier).setQuery,
                onBackTap: () => Navigator.of(context).maybePop(),
                onFilterTap: () => showYourUploadsFilterSheet(context),
              ),
            ),
            SliverToBoxAdapter(
              child: hasVisibleUploads
                  ? YourUploadsActionRow(
                      hasItems: hasVisibleUploads,
                      isUploadBusy: isUploadBusy,
                      onUploadTap: _handleUploadTap,
                      onPlayTap: () => _openFirst(state.filteredItems),
                      onShuffleTap: () => _openRandom(state.filteredItems),
                    )
                  : const SizedBox.shrink(),
            ),
            if (state.quota != null && hasVisibleUploads)
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
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (!hasVisibleUploads)
              SliverFillRemaining(
                hasScrollBody: false,
                child: YourUploadsEmptyState(onUpload: _handleUploadTap),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList.builder(
                  itemCount: state.filteredItems.length,
                  itemBuilder: (_, index) {
                    final item = state.filteredItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: YourUploadsTrackTile(
                        item: item,
                        isBusy: state.busyTrackId == item.id,
                        onTap: _openDetail,
                        onMoreTap: () => _showOptions(item),
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }
}
