import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/routing/routes.dart';
import 'package:software_project/features/auth/presentation/widgets/signout_button.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/blocked_users_screen.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_view_provider.dart';
import 'package:software_project/shared/providers/app_settings_provider.dart';

import '../widgets/library_menu_tile.dart';

const _settingsToggleGreen = Color(0xFF1DB954);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          LibraryMenuTile(
            label: 'Autoplay related tracks',
            onTap: () => settingsNotifier.setAutoplayRelatedTracks(
              !settings.autoplayRelatedTracks,
            ),
            trailing: Switch(
              value: settings.autoplayRelatedTracks,
              onChanged: settingsNotifier.setAutoplayRelatedTracks,
              activeThumbColor: _settingsToggleGreen,
              activeTrackColor: _settingsToggleGreen.withValues(alpha: 0.45),
            ),
          ),
          LibraryMenuTile(
            label: 'Use Classic feed',
            onTap: () {
              final isClassic = ref.read(feedViewModeProvider) == FeedViewMode.classic;
              final next = !isClassic;
              settingsNotifier.setUseClassicFeed(next);
              ref.read(feedViewModeProvider.notifier).setMode(
                next ? FeedViewMode.classic : FeedViewMode.discover,
              );
            },
            trailing: Switch(
              value: ref.watch(feedViewModeProvider) == FeedViewMode.classic,
              onChanged: (val) {
                settingsNotifier.setUseClassicFeed(val);
                ref.read(feedViewModeProvider.notifier).setMode(
                  val ? FeedViewMode.classic : FeedViewMode.discover,
                );
              },
              activeThumbColor: _settingsToggleGreen,
              activeTrackColor: _settingsToggleGreen.withValues(alpha: 0.45),
            ),
          ),
          LibraryMenuTile(
            label: 'Import my music',
            onTap: () => Navigator.of(context).pushNamed(Routes.uploadEntry),
          ),
          LibraryMenuTile(
            label: 'Account',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
          ),
          LibraryMenuTile(
            label: 'Inbox',
            onTap: () => Navigator.of(context).pushNamed(Routes.inboxSettings),
          ),
          LibraryMenuTile(
            label: 'Social',
            onTap: () => _showComingSoon(context, 'Social'),
          ),
          LibraryMenuTile(
            label: 'Blocked Users',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BlockedUsersScreen()
                ),
              );
            },
          ),
          LibraryMenuTile(
            label: 'Notifications',
            onTap: () => _showComingSoon(context, 'Notifications'),
          ),
          LibraryMenuTile(
            label: 'App Icon',
            onTap: () => _showComingSoon(context, 'App Icon'),
          ),
          LibraryMenuTile(
            label: 'App Language',
            onTap: () => _showComingSoon(context, 'App Language'),
          ),
          LibraryMenuTile(
            label: 'Storage',
            onTap: () => _showComingSoon(context, 'Storage'),
          ),
          const SizedBox(height: 15),
          LibraryMenuTile(
            label: 'Analytics',
            onTap: () => _showComingSoon(context, 'Analytics'),
          ),
          LibraryMenuTile(
            label: 'Communications',
            onTap: () => _showComingSoon(context, 'Communications'),
          ),
          LibraryMenuTile(
            label: 'Advertising',
            onTap: () => _showComingSoon(context, 'Advertising'),
          ),
          LibraryMenuTile(
            label: 'Tell a friend',
            onTap: () => _showComingSoon(context, 'Tell a friend'),
          ),
          const SizedBox(height: 15),
          LibraryMenuTile(
            label: 'Troubleshooting',
            onTap: () => _showComingSoon(context, 'Troubleshooting'),
          ),
          LibraryMenuTile(
            label: 'Contact support',
            onTap: () => _showComingSoon(context, 'Contact support'),
          ),
          LibraryMenuTile(
            label: 'Legal',
            onTap: () => _showComingSoon(context, 'Legal'),
          ),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.all(15), child: SignOutButton()),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
  }
}
