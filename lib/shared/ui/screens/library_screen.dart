import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/design_system/colors.dart';

import '../../../features/profile/presentation/providers/profile_provider.dart';
import '../widgets/library_menu_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({
    super.key,
    this.onOpenSettings,
    this.onOpenProfile,
    this.onMenuTap,
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;
  final ValueChanged<String>? onMenuTap;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static const _libraryItems = [
    'Your likes',
    'Playlists',
    'Albums',
    'Following',
    'Stations',
    'Your uploads',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: widget.onOpenSettings,
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
          GestureDetector(onTap: widget.onOpenProfile, child: profileAvatar),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        itemCount: _libraryItems.length,
        itemBuilder: (context, index) {
          final label = _libraryItems[index];

          return LibraryMenuTile(
            label: label,
            onTap: () => _handleMenuTap(context, label, widget.onMenuTap),
          );
        },
      ),
    );
  }

  void _handleMenuTap(
    BuildContext context,
    String label,
    ValueChanged<String>? onMenuTap,
  ) {
    if (onMenuTap != null) {
      onMenuTap(label);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
  }
}
