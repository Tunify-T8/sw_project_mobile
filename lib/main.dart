import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/followers_and_social_graph/presentation/widgets/suggested_users_section.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoundCloud Clone',
      theme: ThemeData.dark(), // 👈 matches your UI better
      home: const SuggestedUsersPreviewScreen(),
    );
  }
}

class SuggestedUsersPreviewScreen extends StatelessWidget {
  const SuggestedUsersPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Suggested Users'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SuggestedUsersSection(),
      ),
    );
  }
}