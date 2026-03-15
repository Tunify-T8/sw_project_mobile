import 'package:flutter/material.dart';
//import 'package:software_project/features/audio_upload_and_management/presentation/screens/artist_home_screen.dart';
//import 'package:software_project/features/audio_upload_and_management/presentation/screens/upload_entry_screen.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/screens/library_screen.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LibraryScreen(),
    );
  }
}