import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
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
    final waveformState = ref.watch(trackDetailWaveformProvider(item));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
      ),
    );
  }
}
