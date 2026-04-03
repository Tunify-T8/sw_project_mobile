import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/design_system/colors.dart';

import '../../../features/profile/presentation/providers/profile_provider.dart';
import '../widgets/library_menu_tile.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({
    super.key,
    this.onOpenSettings,
    this.onOpenProfile,
    this.onMenuTap,
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;
  final ValueChanged<String>? onMenuTap;

  static const _libraryItems = [
    'Your likes',
    'Playlists',
    'Albums',
    'Following',
    'Stations',
    'Your insights',
    'Your uploads',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profileImageUrl = profileState.profile?.profileImagePath;

    final Widget profileAvatar = CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFF9BB4E8),
      backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
          ? NetworkImage(profileImageUrl)
          : null,
      child: (profileImageUrl == null || profileImageUrl.isEmpty)
          ? const Icon(Icons.person, color: Colors.white, size: 22)
          : null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Library', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
          GestureDetector(
            onTap: onOpenProfile,
            child: profileAvatar,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        itemCount: _libraryItems.length,
        itemBuilder: (context, index) {
          final label = _libraryItems[index];

          return LibraryMenuTile(
            label: label,
            onTap: () => _handleMenuTap(context, label),
          );
        },
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String label) {
    if (onMenuTap != null) {
      onMenuTap!(label);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
  }
}