import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/upload_artwork_view.dart';

part 'track_info_screen_header.dart';
part 'track_info_screen_main_card.dart';
part 'track_info_screen_avatar.dart';
part 'track_info_screen_uploader.dart';
part 'track_info_screen_leaderboard.dart';
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
            SliverToBoxAdapter(child: _FanLeaderboard(item: resolvedItem)),
            SliverToBoxAdapter(child: _PlaylistsSection(item: resolvedItem)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
