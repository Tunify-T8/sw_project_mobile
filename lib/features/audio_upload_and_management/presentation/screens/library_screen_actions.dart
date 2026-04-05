part of 'library_screen.dart';

extension _LibraryScreenActions on LibraryScreen {
  void _handleTap(BuildContext context, String label) {
    if (label == 'Following') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const NetworkListsScreen(
            userId: 'u2',
            listType: NetworkListType.following,
            isMyProfile: true,
          ),
        ),
      );
      return;
    }

    if (label == 'Your uploads') {
      if (onOpenYourUploads != null) {
        onOpenYourUploads!();
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YourUploadsScreen(
            onStartUpload: onStartUpload,
            onOpenSubscription: onOpenSubscription,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
