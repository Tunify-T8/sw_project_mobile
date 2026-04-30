import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_notifier.dart';
import '../../../premium_subscription/presentation/screens/upgrade_screen.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/utils/adaptive_breakpoints.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../../../playback_streaming_engine/presentation/screens/open_shared_track_link_screen.dart';
import '../../../playlists/domain/entities/collection_type.dart';
import '../../../playlists/presentation/providers/playlist_providers.dart';
import '../../../playlists/presentation/providers/recent_playlists_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
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
  'Your uploads',
];

const _desktopLibraryMenuItems = [
  'Your likes',
  'Playlists',
  'Albums',
  'Following',
  'Stations',
  'Open shared link',
  'Listening history',
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
      ref.read(playlistNotifierProvider.notifier).loadMyCollections();
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
    final isDesktop = AdaptiveBreakpoints.isExpanded(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AdaptiveCenter(
            child: Padding(
              padding: AdaptiveBreakpoints.pagePadding(context),
              child: Column(
                children: [
                  _DesktopLibraryHeader(
                    profileImageUrl: profileImageUrl,
                    showGetPro:
                        currentSubscription.tier == SubscriptionTier.free,
                    onOpenProfile: widget.onOpenProfile,
                    onOpenSettings: widget.onOpenSettings,
                    onOpenPro: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UpgradeScreen(popUp: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _DesktopLibraryMenu(
                            onTap: (label) => _handleTap(context, label),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 6,
                                child: _DesktopHistoryPane(
                                  historyAsync: historyAsync,
                                  onSeeAll: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ListeningHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Expanded(
                                flex: 4,
                                child: _DesktopRecentPlaylistsPane(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: const Key('library_screen'),
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
                    if (currentSubscription.tier == SubscriptionTier.free) ...[
                      TextButton(
                        key: const Key('library_get_pro_button'),
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

class _DesktopLibraryHeader extends StatelessWidget {
  const _DesktopLibraryHeader({
    required this.profileImageUrl,
    required this.showGetPro,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenPro,
  });

  final String? profileImageUrl;
  final bool showGetPro;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenSettings;
  final VoidCallback onOpenPro;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your listening history, uploads, saved tracks, and creator tools.',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
        if (showGetPro) ...[
          TextButton(
            onPressed: onOpenPro,
            child: const Text(
              'GET PRO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
        IconButton(
          tooltip: 'Settings',
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onOpenProfile,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE7E7E7),
            backgroundImage:
                (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                ? NetworkImage(profileImageUrl!)
                : null,
            child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.black54)
                : null,
          ),
        ),
      ],
    );
  }
}

class _DesktopLibraryMenu extends StatelessWidget {
  const _DesktopLibraryMenu({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _desktopLibraryMenuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (context, index) {
            final label = _desktopLibraryMenuItems[index];
            return _DesktopLibraryTile(
              label: label,
              icon: _libraryIcon(label),
              onTap: () => onTap(label),
            );
          },
        ),
      ),
    );
  }

  IconData _libraryIcon(String label) {
    return switch (label) {
      'Your likes' => Icons.favorite_border,
      'Playlists' => Icons.queue_music_rounded,
      'Albums' => Icons.album_outlined,
      'Following' => Icons.people_outline,
      'Stations' => Icons.radio_outlined,
      'Open shared link' => Icons.link_rounded,
      'Listening history' => Icons.history_rounded,
      'Your uploads' => Icons.cloud_upload_outlined,
      _ => Icons.library_music_outlined,
    };
  }
}

class _DesktopLibraryTile extends StatelessWidget {
  const _DesktopLibraryTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF171717),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5500).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFFF8A3D), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white38,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHistoryPane extends StatelessWidget {
  const _DesktopHistoryPane({
    required this.historyAsync,
    required this.onSeeAll,
  });

  final AsyncValue<ListeningHistoryState> historyAsync;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Listening history',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See all',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF242424)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 18),
              child: historyAsync.when(
                data: (state) {
                  final tracks = state.tracks.take(6).toList();
                  if (tracks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Nothing played yet',
                        style: TextStyle(color: Colors.white38),
                      ),
                    );
                  }
                  return _AnimatedLibraryHistoryPreview(
                    tracks: tracks,
                    queueTracks: state.tracks,
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Could not load listening history',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopRecentPlaylistsPane extends ConsumerWidget {
  const _DesktopRecentPlaylistsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentPlaylistsProvider);
    final playlistState = ref.watch(playlistNotifierProvider);
    final profile = ref.watch(profileProvider).profile;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recently played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.playlists),
                  child: const Text(
                    'See all',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF242424)),
          Expanded(
            child: recentAsync.when(
              data: (items) {
                final displayItems = items.isNotEmpty
                    ? items
                    : playlistState.myCollections
                          .where(
                            (playlist) =>
                                playlist.isMine &&
                                playlist.type == CollectionType.playlist,
                          )
                          .map(
                            (playlist) => RecentPlaylistItem.fromSummary(
                              playlist,
                              ownerName: profile?.userName,
                            ),
                          )
                          .take(10)
                          .toList(growable: false);

                if (displayItems.isEmpty) {
                  if (playlistState.isMyCollectionsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No playlists yet',
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final artSize = (constraints.maxHeight - 32)
                        .clamp(72.0, 104.0)
                        .toDouble();

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      itemBuilder: (context, index) =>
                          _DesktopRecentPlaylistCard(
                            item: displayItems[index],
                            artSize: artSize,
                          ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemCount: displayItems.length,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Could not load recent playlists',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopRecentPlaylistCard extends StatelessWidget {
  const _DesktopRecentPlaylistCard({required this.item, required this.artSize});

  final RecentPlaylistItem item;
  final double artSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.playlistDetail,
        arguments: {'playlistId': item.id, 'isMine': item.isMine},
      ),
      child: SizedBox(
        width: 290,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: artSize,
              height: artSize,
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
                      errorBuilder: (context, error, stackTrace) =>
                          _playlistPlaceholder(),
                    )
                  : _playlistPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistPlaceholder() {
    return const Center(
      child: Icon(Icons.queue_music_rounded, color: Colors.white24, size: 30),
    );
  }
}

class _LibraryRecentlyPlayedPlaylistsSection extends ConsumerWidget {
  const _LibraryRecentlyPlayedPlaylistsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentPlaylistsProvider);
    final playlistState = ref.watch(playlistNotifierProvider);
    final profile = ref.watch(profileProvider).profile;

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
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.playlists),
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
              final displayItems = items.isNotEmpty
                  ? items
                  : playlistState.myCollections
                        .where(
                          (playlist) =>
                              playlist.isMine &&
                              playlist.type == CollectionType.playlist,
                        )
                        .map(
                          (playlist) => RecentPlaylistItem.fromSummary(
                            playlist,
                            ownerName: profile?.userName,
                          ),
                        )
                        .take(10)
                        .toList(growable: false);

              if (displayItems.isEmpty) {
                if (playlistState.isMyCollectionsLoading) {
                  return const SizedBox(
                    height: 96,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Text(
                    'No playlists yet',
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
                  itemBuilder: (context, index) =>
                      _LibraryRecentPlaylistCard(item: displayItems[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemCount: displayItems.length,
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
        arguments: {'playlistId': item.id, 'isMine': item.isMine},
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
                      errorBuilder: (context, error, stackTrace) =>
                          _playlistPlaceholder(),
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
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistPlaceholder() {
    return const Center(
      child: Icon(Icons.queue_music_rounded, color: Colors.white24, size: 32),
    );
  }
}
