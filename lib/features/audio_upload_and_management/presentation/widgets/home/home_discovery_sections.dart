// Upload Feature Guide:
// Purpose: Home surface widget that exposes upload entry points or upload-related discovery sections.
// Used by: home_screen
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/suggested_users_section.dart';

import 'home_liked_by_list.dart';

class HomeDiscoverySections extends StatelessWidget {
  const HomeDiscoverySections({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        _SectionTitle(title: 'Made for you', topPadding: 24),
        _MadeForYouList(),
        _SectionTitle(title: 'Liked By', topPadding: 24),
        HomeLikedByList(),
        _SectionTitle(title: 'Suggested users', topPadding: 24),
        SuggestedUsersSection(),
        SizedBox(height: 120),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.topPadding});

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MadeForYouList extends StatelessWidget {
  const _MadeForYouList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: const [
          _MadeForYouCard(
            color: Color(0xFF1A2A5A),
            label: 'DAILY',
            labelBold: 'DROPS',
            sub: 'New releases based on your taste. Updated every day',
          ),
          SizedBox(width: 12),
          _MadeForYouCard(
            color: Color(0xFF5A1A2A),
            label: 'WEEKLY',
            labelBold: 'WAVE',
            sub: 'The best of SoundCloud just for you. Updated every Monday',
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _MadeForYouCard extends StatelessWidget {
  const _MadeForYouCard({
    required this.color,
    required this.label,
    required this.labelBold,
    required this.sub,
  });

  final Color color;
  final String label;
  final String labelBold;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: color.withValues(alpha: 0.7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    labelBold,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
