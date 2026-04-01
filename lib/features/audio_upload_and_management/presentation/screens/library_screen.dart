import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';

import '../../../../core/design_system/colors.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/domain/entities/player_seed_track.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../utils/playback_surface_item_mapper.dart';
import '../utils/upload_player_launcher.dart';
import 'your_uploads_screen.dart';

part 'library_screen_actions.dart';
part 'library_screen_history_tile.dart';

const _libraryMenuItems = [
  'Your likes',
  'Playlists',
  'Albums',
  'Following',
  'Stations',
  'Your insights',
  'Your uploads',
];

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({
    super.key,
    this.onOpenSettings,
    this.onOpenProfile,
    this.onStartUpload,
    this.onOpenSubscription,
    this.onOpenYourUploads,
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onStartUpload;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenYourUploads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Library',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: onOpenProfile,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE7E7E7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _libraryMenuItems.length,
              itemBuilder: (context, index) {
                final label = _libraryMenuItems[index];
                return InkWell(
                  onTap: () => _handleTap(context, label),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Listening history',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ListeningHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            historyAsync.when(
              data: (state) {
                final tracks = state.tracks.take(4).toList();
                if (tracks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                      child: Text(
                        'Nothing played yet',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _LibraryHistoryTile(
                      track: track,
                      queueTracks: state.tracks,
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (_, _) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                  child: Text(
                    'Could not load listening history',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }
}
