import 'package:flutter/material.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/suggested_users_section.dart';

import 'home_liked_by_list.dart';

part 'home_discovery_sections_parts.dart';

class HomeDiscoverySections extends StatelessWidget {
  const HomeDiscoverySections({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        _SectionTitle(
          title: 'Today\'s pick',
          topPadding: 28,
          eyebrow: 'HOT FOR YOU',
        ),
        _FeaturedPickCard(),
        _SectionTitle(title: 'More of what you like', topPadding: 28),
        _MadeForYouList(),
        _SectionTitle(title: 'Liked by', topPadding: 28),
        HomeLikedByList(),
        _SectionTitle(title: 'Suggested users', topPadding: 28),
        SuggestedUsersSection(),
        SizedBox(height: 120),
      ],
    );
  }
}
