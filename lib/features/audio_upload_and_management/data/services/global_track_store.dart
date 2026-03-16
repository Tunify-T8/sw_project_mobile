import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_item.dart';

/// Singleton in-memory store for uploaded tracks.
/// Both MockUploadService and MockLibraryUploadsApi read/write here,
/// so a new upload immediately shows up in YourUploadsScreen.
class GlobalTrackStore {
  GlobalTrackStore._();
  static final GlobalTrackStore instance = GlobalTrackStore._();

  final List<UploadItem> _items = [];

  List<UploadItem> get all => List.unmodifiable(_items);

  void add(UploadItem item) {
    _items.removeWhere((e) => e.id == item.id);
    _items.insert(0, item); // newest first
  }

  void update(UploadItem item) {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.insert(0, item);
    }
  }

  void remove(String id) => _items.removeWhere((e) => e.id == id);

  UploadItem? find(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod provider – exposes the store so notifiers can read it.
final globalTrackStoreProvider = Provider<GlobalTrackStore>((ref) {
  return GlobalTrackStore.instance;
});
