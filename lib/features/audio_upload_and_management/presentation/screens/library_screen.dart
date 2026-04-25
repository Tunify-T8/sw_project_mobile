import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';

import '../../../../core/design_system/colors.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../../../playback_streaming_engine/presentation/screens/open_shared_track_link_screen.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../data/services/global_track_store.dart';
import '../../../engagements_social_interactions/presentation/screens/liked_tracks_screen.dart'; // engagement addition
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
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(listeningHistoryProvider);
    final profileImageUrl = ref.watch(profileProvider).profile?.profileImagePath;

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
                      onPressed: widget.onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: widget.onOpenProfile,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE7E7E7),
                        backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: (profileImageUrl == null || profileImageUrl.isEmpty)
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
              child: _LibraryRecentlyPlayedPlaylistsSection(
                onSeeAll: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF1C1C1E),
                      content: Text(
                        'Recently played playlists will appear when Playlists module is plugged in',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
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


class _LibraryRecentlyPlayedPlaylistsSection extends StatelessWidget {
  const _LibraryRecentlyPlayedPlaylistsSection({required this.onSeeAll});

  final VoidCallback onSeeAll;

  static const _items = <_LibraryRecentPlaylistItem>[
    _LibraryRecentPlaylistItem(
      title: 'Pop Fit Workout',
      subtitle: 'Discovery Playlists',
      accentIcon: Icons.cloud,
      colors: [Color(0xFF6BC7FF), Color(0xFF2B6CFF)],
    ),
    _LibraryRecentPlaylistItem(
      title: 'Related tracks: Kendrick Lamar',
      subtitle: 'SoundCloud',
      accentIcon: Icons.lock,
      colors: [Color(0xFF102D35), Color(0xFF00A98F)],
    ),
    _LibraryRecentPlaylistItem(
      title: 'Related tracks: Everything Is Romantic',
      subtitle: 'SoundCloud',
      accentIcon: Icons.lock,
      colors: [Color(0xFF221E1C), Color(0xFF51443A)],
    ),
    _LibraryRecentPlaylistItem(
      title: 'Related tracks: Ocean Eyes',
      subtitle: 'SoundCloud',
      accentIcon: Icons.lock,
      colors: [Color(0xFF404040), Color(0xFFDADADA)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
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
                onPressed: onSeeAll,
                child: const Text(
                  'See all',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = _items[index];
              return _LibraryRecentPlaylistCard(
                item: item,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF1C1C1E),
                      content: Text(
                        'Playlist opening is waiting for the Playlists module',
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LibraryRecentPlaylistItem {
  const _LibraryRecentPlaylistItem({
    required this.title,
    required this.subtitle,
    required this.accentIcon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData accentIcon;
  final List<Color> colors;
}

class _LibraryRecentPlaylistCard extends StatelessWidget {
  const _LibraryRecentPlaylistCard({
    required this.item,
    required this.onTap,
  });

  final _LibraryRecentPlaylistItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                gradient: LinearGradient(
                  colors: item.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Icon(
                      Icons.graphic_eq,
                      color: Colors.white.withValues(alpha: 0.28),
                      size: 72,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      item.accentIcon,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 16,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
