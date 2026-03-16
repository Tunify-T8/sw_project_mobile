import 'package:flutter/material.dart';

class LibraryMenuTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const LibraryMenuTile({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 28.0,
          ),
      onTap: onTap,
    );
  }
}