import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/audio_upload_and_management/presentation/screens/home_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/library_screen.dart';

/// SoundCloud-style bottom nav: Home | Feed | Search | Library | Upgrade
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
          const _PlaceholderTab(label: 'Feed'),
          const _PlaceholderTab(label: 'Search'),
          LibraryScreen(
            onOpenYourUploads: () =>
                Navigator.of(context).pushNamed('/your-uploads'),
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
}
