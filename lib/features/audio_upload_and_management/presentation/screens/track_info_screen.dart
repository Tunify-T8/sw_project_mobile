import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/navigation_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../../../shared/ui/widgets/track_options_menu/track_options_menu.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/upload_artwork_view.dart';

part 'track_info_screen_header.dart';
part 'track_info_screen_main_card.dart';
part 'track_info_screen_avatar.dart';
part 'track_info_screen_uploader.dart';
part 'track_info_screen_playlists.dart';
part 'track_info_screen_data.dart';

class TrackInfoScreen extends ConsumerWidget {
  const TrackInfoScreen({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(item: resolvedItem)),
            SliverToBoxAdapter(child: _MainTrackCard(item: resolvedItem)),
            SliverToBoxAdapter(child: _UploaderCard(item: resolvedItem)),
            SliverToBoxAdapter(child: _PlaylistsSection(item: resolvedItem)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

String? _resolveTrackArtistId(WidgetRef ref, String trackId) {
  final storeOwner = ref.read(globalTrackStoreProvider).ownerUserIdForTrack(
    trackId,
  );
  if (storeOwner != null &&
      storeOwner.isNotEmpty &&
      storeOwner != '__global__') {
    return storeOwner;
  }

  final bundle = ref.read(playerProvider).asData?.value.bundle;
  if (bundle != null && bundle.trackId == trackId) {
    final id = bundle.artist.id.trim();
    if (id.isNotEmpty) return id;
  }

  return null;
}
