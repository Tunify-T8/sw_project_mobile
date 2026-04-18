import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/routing/routes.dart';

import '../features/audio_upload_and_management/presentation/screens/home_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/library_screen.dart';
import '../features/feed_search_discovery/presentation/screens/feed_screen.dart';
import '../features/feed_search_discovery/presentation/screens/search_screen.dart';
import '../features/playback_streaming_engine/presentation/widgets/mini_player.dart';
import 'router.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  /// Allows pushed screens (e.g. messaging) to switch the active bottom tab
  /// before popping back. The shell listens to this notifier and rebuilds.
  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    MainShellScreen.tabNotifier.addListener(_onExternalTabChange);
  }

  @override
  void dispose() {
    MainShellScreen.tabNotifier.removeListener(_onExternalTabChange);
    super.dispose();
  }

  void _onExternalTabChange() {
    final next = MainShellScreen.tabNotifier.value;
    if (mounted && next != _index) setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D0D), Color(0xFF050505)],
          ),
        ),
        child: IndexedStack(
          index: _index,
          children: [
            const HomeScreen(),
            const FeedScreen(),
            const SearchScreen(),
            LibraryScreen(
              onOpenSettings: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
              onOpenProfile: () =>
                  Navigator.of(context).pushNamed(AppRoutes.profile),
              onOpenYourUploads: () =>
                  Navigator.of(context).pushNamed(Routes.yourUploads),
            ),
            const _PlaceholderTab(label: 'Upgrade'),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
          color: Color(0xFF090909),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hide the mini player on the Feed tab (index 1) — the full
            // player screen is used there instead.
            if (_index != 1) const MiniPlayer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: _SCBottomBar(
                selectedIndex: _index,
                onTap: (i) {
                  MainShellScreen.tabNotifier.value = i;
                  setState(() => _index = i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.white38, fontSize: 20),
      ),
    ),
  );
}

class _SCBottomBar extends StatelessWidget {
  const _SCBottomBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavData('Home', Icons.home_filled, Icons.home_outlined),
    _NavData('Feed', Icons.dynamic_feed, Icons.dynamic_feed_outlined),
    _NavData('Search', Icons.search, Icons.search),
    _NavData('Library', Icons.library_books, Icons.library_books_outlined),
    _NavData('Upgrade', Icons.graphic_eq, Icons.graphic_eq_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        final selected = index == selectedIndex;
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? item.activeIcon : item.inactiveIcon,
                    color: selected ? Colors.white : const Color(0xFF808080),
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF808080),
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NavData {
  const _NavData(this.label, this.activeIcon, this.inactiveIcon);

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}
