import 'package:flutter/material.dart';
import 'home_placeholder_card.dart';

class HomeCardsGrid extends StatelessWidget {
  const HomeCardsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: const [
        HomePlaceholderCard(title: 'Recent Uploads'),
        HomePlaceholderCard(title: 'Draft Tracks'),
        HomePlaceholderCard(title: 'Performance'),
        HomePlaceholderCard(title: 'Audience'),
      ],
    );
  }
}
