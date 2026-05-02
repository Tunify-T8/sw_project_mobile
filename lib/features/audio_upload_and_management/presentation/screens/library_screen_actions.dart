part of 'library_screen.dart';

extension _LibraryScreenActions on _LibraryScreenState {
  void _handleTap(BuildContext context, String label) {
    if (label == 'Playlists' || label == 'Albums') {
      Navigator.of(context).pushNamed(Routes.playlists);
      return;
    }

    if (label == 'Your likes') {
      // engagement addition — navigate to liked tracks screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LikedTracksScreen()));
      return;
    }

    if (label == 'Following') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const NetworkListsScreen(listType: NetworkListType.following),
        ),
      );
      return;
    }

    if (label == 'Your uploads') {
      if (widget.onOpenYourUploads != null) {
        widget.onOpenYourUploads!();
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YourUploadsScreen(
            onStartUpload: widget.onStartUpload,
            onOpenSubscription: widget.onOpenSubscription,
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
