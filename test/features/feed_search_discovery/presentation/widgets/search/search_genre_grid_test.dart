import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_genre_grid.dart';

import '../../../../../test_utils/mock_network_images.dart';

void main() {
  testWidgets('shows loading indicator while genres are loading', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SearchGenreGrid(
              genres: [],
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders backend genre labels and invokes tap callback', (tester) async {
    SearchGenreEntity? tappedGenre;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SearchGenreGrid(
              genres: const [
                SearchGenreEntity(
                  id: 'hip_hop_rap',
                  label: 'Backend Hip Hop',
                  colorValue: 0xFFA259FF,
                ),
              ],
              isLoading: false,
              onGenreTap: (genre) => tappedGenre = genre,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Vibes'), findsOneWidget);
    expect(find.text('Backend Hip Hop'), findsOneWidget);

    await tester.tap(find.text('Backend Hip Hop'));
    await tester.pumpAndSettle();

    expect(tappedGenre?.id, 'hip_hop_rap');
    expect(find.text('Backend Hip Hop'), findsWidgets);
  });

  testWidgets('renders artwork branch and falls back to local config for unknown ids', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchGenreGrid(
                genres: const [
                  SearchGenreEntity(
                    id: 'electronic',
                    label: 'Electronic',
                    colorValue: 0xFFFF4FA3,
                    artworkUrl: 'https://example.com/genre.png',
                  ),
                ],
                isLoading: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    });

    expect(find.text('Electronic'), findsWidgets);
    expect(find.text('Hip Hop & Rap'), findsOneWidget);
  });
}
