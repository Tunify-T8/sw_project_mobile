import 'package:flutter/material.dart';

import '../widgets/library/library_header.dart';
import '../widgets/library/library_history_sections.dart';
import '../widgets/library/library_menu_list.dart';
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
            SliverToBoxAdapter(
              child: LibraryHeader(
                onOpenSettings: onOpenSettings,
                onOpenProfile: onOpenProfile,
              ),
            ),
            LibraryMenuList(
              items: _menuItems,
              onTap: (label) => _handleTap(context, label),
            ),
            const LibraryHistorySections(),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
