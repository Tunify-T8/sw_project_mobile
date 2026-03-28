import 'package:flutter/material.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_track_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return FeedTrackCard();
              },
            ),
            Positioned(
              top: 65.0,
              left: 0.0,
              right: 0.0,
              child: Center(child: SizedBox(width: 220, child: FeedTabBar())),
            ),
          ],
        ),
      ),
    );
  }
}
