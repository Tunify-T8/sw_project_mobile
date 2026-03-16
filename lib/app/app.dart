import 'package:flutter/material.dart';
import 'router.dart';
import '../core/routing/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoundCloud Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5500),
          secondary: Color(0xFF9C27B0),
        ),
      ),
      initialRoute: Routes.shell,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
