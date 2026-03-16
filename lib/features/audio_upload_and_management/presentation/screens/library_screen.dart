import 'package:flutter/material.dart';
import 'your_uploads_screen.dart';

/// SoundCloud Library screen — exact match to screenshot.
/// List: Your likes, Playlists, Albums, Following, Stations, Your insights, Your uploads
/// Then: Recently played (horizontal scroll), Listening history
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

  static const _menuItems = [
    'Your likes',
    'Playlists',
    'Albums',
    'Following',
    'Stations',
    'Your insights',
    'Your uploads',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Library',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white, size: 26),
                      onPressed: onOpenSettings ?? () {},
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onOpenProfile ?? () {},
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9BB4E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),

            // ── Menu list ────────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final label = _menuItems[index];
                  return _MenuItem(
                    label: label,
                    onTap: () => _handleTap(context, label),
                  );
                },
                childCount: _menuItems.length,
              ),
            ),

            // ── Recently played ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recently played',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: const [
                    _RecentCard(title: 'Pop Fit Workout', sub: 'Discovery Playlists'),
                    SizedBox(width: 14),
                    _RecentCard(title: 'Related tracks:...', sub: 'SoundCloud'),
                    SizedBox(width: 14),
                    _RecentCard(title: 'Related tracks:...', sub: 'SoundCloud'),
                    SizedBox(width: 20),
                  ],
                ),
              ),
            ),

            // ── Listening history ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Listening history',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String label) {
    if (label == 'Your uploads') {
      if (onOpenYourUploads != null) {
        onOpenYourUploads!();
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => YourUploadsScreen(onStartUpload: onStartUpload),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.title, required this.sub});
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E2B97), Color(0xFFB91372), Color(0xFFFAB72A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
