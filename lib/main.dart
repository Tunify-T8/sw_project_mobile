import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/feed_search_discovery/presentation/widgets/trending_genre_section.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePreview(),
    );
  }
}

class HomePreview extends StatelessWidget {
  const HomePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Trending by genre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Padding(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}