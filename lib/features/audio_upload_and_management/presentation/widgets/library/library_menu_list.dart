import 'package:flutter/material.dart';

class LibraryMenuList extends StatelessWidget {
  const LibraryMenuList({super.key, required this.items, required this.onTap});

  final List<String> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final label = items[index];
        return InkWell(
          onTap: () => onTap(label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }, childCount: items.length),
    );
  }
}
