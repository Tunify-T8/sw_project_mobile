// Upload Feature Guide:
// Purpose: Track detail surface for playback, waveform display, and per-track actions.
// Used by: home_screen, your_uploads_screen
// Concerns: Track visibility.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import '../providers/track_detail_waveform_provider.dart';
import '../widgets/track_detail/track_detail_background.dart';
import '../widgets/track_detail/track_detail_header.dart';
import '../widgets/track_detail/track_detail_more_sheet.dart';
import '../widgets/track_detail/track_detail_waveform_panel.dart';

class TrackDetailScreen extends ConsumerWidget {
  const TrackDetailScreen({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _TrackDetailBody(
        key: ValueKey(_buildTrackDetailRefreshKey(resolvedItem)),
        item: resolvedItem,
      ),
    );
  }
}

class _TrackDetailBody extends ConsumerWidget {
  const _TrackDetailBody({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waveformState = ref.watch(trackDetailWaveformProvider(item));

    return Stack(
      children: [
        TrackDetailBackground(
          item: item,
          fallbackColor: const Color(0xFF3A5A8A),
        ),
        TrackDetailHeader(
          item: item,
          onDismiss: () => Navigator.of(context).pop(),
        ),
        TrackDetailWaveformPanel(
          item: item,
          state: waveformState,
          onMoreTap: () => showTrackDetailMoreSheet(context, ref, item),
        ),
      ],
    );
  }
}

String _buildTrackDetailRefreshKey(UploadItem item) {
  return [
    item.id,
    item.title,
    item.artistDisplay,
    item.waveformUrl ?? '',
    item.artworkUrl ?? '',
    item.description ?? '',
    item.durationSeconds.toString(),
  ].join('|');
}
