import 'package:flutter/material.dart';

class FeedTabBar extends StatelessWidget {
  final TabController controller;
  const FeedTabBar({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: const [
        Tab(text: 'Discover'),
        Tab(text: 'Following'),
      ],
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicator: BoxDecoration(
        color: Color(0xFF3A3A3B),
        borderRadius: BorderRadius.circular(20),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      splashBorderRadius: BorderRadius.circular(20),
    );
  }
}