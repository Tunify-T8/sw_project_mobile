import 'package:flutter/material.dart';

import 'track_option_menu_item.dart';

class TrackMoreActions extends StatelessWidget {
  final bool isMyTrack;
  final bool isBehindTrack;

  const TrackMoreActions({
    super.key,
    required this.isMyTrack,
    required this.isBehindTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isBehindTrack)
          TrackOptionMenuItem(
            icon: Icons.graphic_eq,
            label: 'Behind this track',
            onTap: () {},
          ),

        if (!isMyTrack)
          TrackOptionMenuItem(
            icon: Icons.flag_outlined,
            label: 'Report',
            onTap: () {},
          ),
      ],
    );
  }
}