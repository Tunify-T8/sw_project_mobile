import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NetworkListsScreen(
        userId: 'u2',
        listType: NetworkListType.blocked,
      ),
    );
  }
}