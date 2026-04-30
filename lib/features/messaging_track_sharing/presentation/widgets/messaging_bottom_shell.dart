import 'package:flutter/material.dart';

import '../../../../app/main_shell_screen.dart';
import '../../../../core/utils/adaptive_breakpoints.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';

/// Bottom area shown on messaging screens — replicates the main shell layout:
/// MiniPlayer on top, then the five-tab navigation bar at the bottom.
///
/// Tapping any tab pops all routes above the main shell so the user lands
/// back on the requested tab.
class MessagingBottomShell extends StatelessWidget {
  const MessagingBottomShell({super.key, this.selectedIndex = 0, this.above});

  /// Which bottom-bar tab to highlight (0 = Home, etc.).
  final int selectedIndex;

  /// Optional widget to show above the mini-player (e.g. ChatInputBar).
  final Widget? above;

  @override
  Widget build(BuildContext context) {
    if (AdaptiveBreakpoints.isExpanded(context)) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
          color: Color(0xFF090909),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [?above, const MiniPlayer()],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
        color: Color(0xFF090909),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?above,
          const MiniPlayer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: _BottomBar(
              selectedIndex: selectedIndex,
              onTap: (i) {
                MainShellScreen.tabNotifier.value = i;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private bottom nav bar (visual clone of the main shell bar) ─────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onTap});

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
