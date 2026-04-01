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

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
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
            const _PlaceholderTab(label: 'Feed'),
            const _PlaceholderTab(label: 'Search'),
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
            const MiniPlayer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: _SCBottomBar(
                selectedIndex: _index,
                onTap: (i) => setState(() => _index = i),
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
} /*
 body: IndexedStack(
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
      bottomNavigationBar: _SCBottomBar(
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),















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









  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF777777),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        iconSize: 22,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed_outlined),
            activeIcon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq_outlined),
            activeIcon: Icon(Icons.graphic_eq),
            label: 'Upgrade',
          ),
        ],
      ),
    );
  }
} */
