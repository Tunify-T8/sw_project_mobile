import 'package:flutter/material.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/suggested_users_section.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/trending_genre_section.dart';
import '../../../../followers_and_social_graph/domain/entities/network_list_type.dart';

part 'home_discovery_sections_parts.dart';

class HomeDiscoverySections extends StatelessWidget {
  const HomeDiscoverySections({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        _SectionTitle(title: 'Suggested users', topPadding: 28),
        SuggestedUsersSection(listType: NetworkListType.suggestedUsers),
        _SectionTitle(title: 'Suggested artists', topPadding: 28),
        SuggestedUsersSection(listType: NetworkListType.suggestedArtists),
        _SectionTitle(title: 'Trending by genre', topPadding: 28),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TrendingGenreSection(
            genres: [
              'Jazz',
              'Rock, Metal, Punk',
              'Soul',
              'Pop',
              'Hip Hop & Rap',
              'House',
              'SoundCloud',
              'R&B',
              'Folk',
              'Latin',
              'Indie',
              'Techno',
              'Country',
              'Reggae',
              'Electronic',
            ],
          ),
        ),
        SizedBox(height: 120),
      ],
    );
  }
}
