import 'package:flutter/material.dart';

class NetworkListsEmptyState extends StatelessWidget {
  const NetworkListsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.white70, size: 42),
            SizedBox(height: 12),
            Text(
              'No users found',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}