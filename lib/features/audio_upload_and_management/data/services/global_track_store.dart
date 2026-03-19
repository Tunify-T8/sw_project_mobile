import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';

/// Singleton in-memory store for uploaded tracks.
/// Both MockUploadService and MockLibraryUploadsApi read/write here,
/// so a new upload immediately shows up in YourUploadsScreen.
class GlobalTrackStore {
  GlobalTrackStore._();

  static final GlobalTrackStore instance = GlobalTrackStore._();
  static const String _globalOwnerId = '__global__';

  final Map<String, List<UploadItem>> _itemsByOwner = {};
  final Map<String, String> _ownersByTrackId = {};

  List<UploadItem> get all =>
      List.unmodifiable(_itemsByOwner.values.expand((items) => items).toList());

  List<UploadItem> allForUser(String ownerUserId) =>
      List.unmodifiable(_itemsByOwner[ownerUserId] ?? const <UploadItem>[]);

  String? ownerUserIdForTrack(String id) => _ownersByTrackId[id];

  void add(UploadItem item, {String ownerUserId = _globalOwnerId}) {
    final resolvedOwner = _ownersByTrackId[item.id] ?? ownerUserId;
    _removeFromBuckets(item.id);
    final bucket = _itemsByOwner.putIfAbsent(resolvedOwner, () => []);
    bucket.insert(0, item);
    _ownersByTrackId[item.id] = resolvedOwner;
  }

  void clear({String? ownerUserId}) {
    if (ownerUserId == null) {
      _itemsByOwner.clear();
      _ownersByTrackId.clear();
      return;
    }

    final removed = _itemsByOwner.remove(ownerUserId) ?? const <UploadItem>[];
    for (final item in removed) {
      _ownersByTrackId.remove(item.id);
    }
  }

  void update(UploadItem item, {String? ownerUserId}) {
    add(
      item,
      ownerUserId: ownerUserId ?? _ownersByTrackId[item.id] ?? _globalOwnerId,
    );
  }

  void remove(String id) {
    _removeFromBuckets(id);
    _ownersByTrackId.remove(id);
  }

  UploadItem? find(String id) {
    final ownerUserId = _ownersByTrackId[id];
    if (ownerUserId != null) {
      for (final item in _itemsByOwner[ownerUserId] ?? const <UploadItem>[]) {
        if (item.id == id) {
          return item;
        }
      }
    }

    for (final item in all) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  void _removeFromBuckets(String id) {
    for (final entry in _itemsByOwner.entries.toList()) {
      entry.value.removeWhere((item) => item.id == id);
      if (entry.value.isEmpty) {
        _itemsByOwner.remove(entry.key);
      }
    }
  }
}

/// Riverpod provider exposes the singleton store so notifiers can read it.
final globalTrackStoreProvider = Provider<GlobalTrackStore>((ref) {
  return GlobalTrackStore.instance;
});
