import 'package:flutter/material.dart';

class TrendingGenreBar extends StatelessWidget {
  final TabController controller;
  final List<String> genres;

  const TrendingGenreBar({
    super.key,
    required this.controller,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabs: genres.map((genre) => Tab(text: genre)).toList(),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelColor: const Color(0xFF4ADE80),
      unselectedLabelColor: Colors.white54,
      indicator: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4ADE80),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      splashBorderRadius: BorderRadius.circular(20),
      tabAlignment: TabAlignment.start,
    );
  }
}