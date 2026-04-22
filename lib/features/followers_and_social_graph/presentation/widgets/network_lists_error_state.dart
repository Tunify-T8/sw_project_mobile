import 'package:flutter/material.dart';

class NetworkListsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkListsErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.white70),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(key: const Key('retry_button'), onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
