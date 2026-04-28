import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_notifier.dart';
import '../../../premium_subscription/presentation/screens/upgrade_screen.dart';
import '../../../../core/design_system/colors.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../../../playback_streaming_engine/presentation/screens/open_shared_track_link_screen.dart';
import '../../../playlists/presentation/providers/recent_playlists_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../../../shared/ui/widgets/track_options_menu/track_options_menu.dart';
import '../../data/services/global_track_store.dart';
import '../../../engagements_social_interactions/presentation/screens/liked_tracks_screen.dart';
import '../../domain/entities/upload_item.dart';
import '../utils/playback_surface_item_mapper.dart';
import '../utils/upload_player_launcher.dart';
import '../../../../core/routing/routes.dart';
import 'your_uploads_screen.dart';

part 'library_screen_actions.dart';
part 'library_screen_history_tile.dart';

const _libraryMenuItems = [
  'Your likes',
  'Playlists',
  'Albums',
  'Following',
  'Stations',
  'Open shared link',
  'Your insights',
  'Your uploads',
];

class LibraryScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(subscriptionNotifierProvider.notifier).loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(listeningHistoryProvider);
    final profileImageUrl = ref
        .watch(profileProvider)
        .profile
        ?.profileImagePath;
    final currentSubscription = ref
        .watch(subscriptionNotifierProvider)
        .currentSubscription;

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
                    if (currentSubscription?.tier == SubscriptionTier.free) ...[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UpgradeScreen(popUp: true),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          overlayColor: Colors.transparent,
                        ),
                        child: const Text(
                          "GET PRO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    IconButton(
                      onPressed: widget.onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: widget.onOpenProfile,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE7E7E7),
                        backgroundImage:
                            (profileImageUrl != null &&
                                profileImageUrl.isNotEmpty)
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child:
                            (profileImageUrl == null || profileImageUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.black54)
                            : null,
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
              child: const _LibraryRecentlyPlayedPlaylistsSection(),
            ),
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
                return SliverToBoxAdapter(
                  child: _AnimatedLibraryHistoryPreview(
                    tracks: tracks,
                    queueTracks: state.tracks,
                  ),
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

class _LibraryRecentlyPlayedPlaylistsSection extends ConsumerWidget {
  const _LibraryRecentlyPlayedPlaylistsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentPlaylistsProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recently played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    Routes.playlists,
                  ),
                  child: const Text(
                    'See all',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          recentAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Text(
                    'No playlists played yet',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }

              return SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemBuilder: (context, index) => _LibraryRecentPlaylistCard(
                    item: items[index],
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: items.length,
                ),
              );
            },
            loading: () => const SizedBox(
              height: 96,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                'Could not load recent playlists',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryRecentPlaylistCard extends StatelessWidget {
  const _LibraryRecentPlaylistCard({required this.item});

  final RecentPlaylistItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.playlistDetail,
        arguments: {
          'playlistId': item.id,
          'isMine': item.isMine,
        },
      ),
      child: SizedBox(
        width: 138,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                color: const Color(0xFF202020),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white10),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.coverUrl?.isNotEmpty == true
                  ? Image.network(
                      item.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _playlistPlaceholder(),
                    )
                  : _playlistPlaceholder(),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistPlaceholder() {
    return const Center(
      child: Icon(
        Icons.queue_music_rounded,
        color: Colors.white24,
        size: 32,
      ),
    );
  }
}
