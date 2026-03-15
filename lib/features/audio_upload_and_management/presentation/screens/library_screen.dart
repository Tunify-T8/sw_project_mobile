import 'package:flutter/material.dart';

import '../widgets/library_section_tile.dart';
import 'your_uploads_screen.dart';

class LibraryScreen extends StatelessWidget {
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

  static const double _bottomReservedHeight = 168;

  @override
  Widget build(BuildContext context) {
    final items = <_LibraryMenuItem>[
      const _LibraryMenuItem(label: 'Your likes'),
      const _LibraryMenuItem(label: 'Playlists'),
      const _LibraryMenuItem(label: 'Albums'),
      const _LibraryMenuItem(label: 'Following'),
      const _LibraryMenuItem(label: 'Stations'),
      const _LibraryMenuItem(label: 'Your insights'),
      const _LibraryMenuItem(label: 'Your uploads'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Library',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: onOpenSettings ??
                              () => _showComingSoon(context, 'Settings'),
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onOpenProfile ??
                              () => _showComingSoon(context, 'Profile'),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LibrarySectionTile(
                        title: item.label,
                        onTap: () => _handleMenuTap(
                          context,
                          item.label,
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                child: Row(
                  children: [
                    const Text(
                      'Recently played',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showComingSoon(context, 'Recently played'),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 235,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _RecentPlayedCard(
                      title: 'Related tracks: Sia - Chandelier',
                      subtitle: 'SoundCloud',
                    ),
                    SizedBox(width: 16),
                    _RecentPlayedCard(
                      title: 'مهرجان وش غضب',
                      subtitle: 'SoundCloud',
                    ),
                    SizedBox(width: 16),
                    _RecentPlayedCard(
                      title: 'حلقات جديدة',
                      subtitle: 'SoundCloud',
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: _bottomReservedHeight),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String label) {
    if (label == 'Your uploads') {
      if (onOpenYourUploads != null) {
        onOpenYourUploads!.call();
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YourUploadsScreen(
            onStartUpload: onStartUpload,
            onOpenSubscription: onOpenSubscription,
          ),
        ),
      );
      return;
    }

    _showComingSoon(context, label);
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label is not wired yet.'),
      ),
    );
  }
}

class _LibraryMenuItem {
  final String label;

  const _LibraryMenuItem({
    required this.label,
  });
}

class _RecentPlayedCard extends StatelessWidget {
  const _RecentPlayedCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5E2B97),
                  Color(0xFFB91372),
                  Color(0xFFFAB72A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}