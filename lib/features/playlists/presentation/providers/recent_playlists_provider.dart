import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';

class RecentPlaylistItem {
  const RecentPlaylistItem({
    required this.id,
    required this.title,
    required this.trackCount,
    required this.isMine,
    required this.playedAt,
    this.ownerName,
    this.coverUrl,
  });

  final String id;
  final String title;
  final int trackCount;
  final bool isMine;
  final DateTime playedAt;
  final String? ownerName;
  final String? coverUrl;

  String get subtitle {
    final countLabel = '$trackCount track${trackCount == 1 ? '' : 's'}';
    final owner = ownerName?.trim();
    return owner == null || owner.isEmpty ? countLabel : '$owner - $countLabel';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'trackCount': trackCount,
      'isMine': isMine,
      'playedAt': playedAt.toIso8601String(),
      'ownerName': ownerName,
      'coverUrl': coverUrl,
    };
  }

  factory RecentPlaylistItem.fromJson(Map<String, dynamic> json) {
    return RecentPlaylistItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      trackCount: (json['trackCount'] as int?) ?? 0,
      isMine: json['isMine'] as bool? ?? true,
      playedAt:
          DateTime.tryParse((json['playedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      ownerName: json['ownerName'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  factory RecentPlaylistItem.fromPlaylist(
    PlaylistEntity playlist, {
    required bool isMine,
    String? coverUrl,
  }) {
    final owner = playlist.owner;
    return RecentPlaylistItem(
      id: playlist.id,
      title: playlist.title,
      trackCount: playlist.trackCount,
      isMine: isMine,
      playedAt: DateTime.now(),
      ownerName: owner?.displayName ?? owner?.username,
      coverUrl: (coverUrl?.trim().isNotEmpty == true)
          ? coverUrl
          : playlist.coverUrl,
    );
  }

  factory RecentPlaylistItem.fromSummary(
    PlaylistSummaryEntity playlist, {
    String? ownerName,
  }) {
    return RecentPlaylistItem(
      id: playlist.id,
      title: playlist.title,
      trackCount: playlist.trackCount,
      isMine: playlist.isMine,
      playedAt: playlist.updatedAt,
      ownerName: ownerName,
      coverUrl: playlist.coverUrl,
    );
  }
}

class RecentPlaylistsNotifier extends AsyncNotifier<List<RecentPlaylistItem>> {
  static const int _limit = 10;

  String _userId = '';

  String get _storageKey => _userId.isEmpty
      ? StorageKeys.cachedRecentPlaylists
      : '${StorageKeys.cachedRecentPlaylists}_$_userId';

  @override
  Future<List<RecentPlaylistItem>> build() async {
    _userId = (await const TokenStorage().getUser())?.id.trim() ?? '';
    return _readCached();
  }

  Future<void> record(
    PlaylistEntity playlist, {
    required bool isMine,
    String? coverUrl,
  }) async {
    if (_userId.isEmpty) {
      _userId = (await const TokenStorage().getUser())?.id.trim() ?? '';
    }

    final item = RecentPlaylistItem.fromPlaylist(
      playlist,
      isMine: isMine,
      coverUrl: coverUrl,
    );

    final current = state.asData?.value ?? await _readCached();
    final next = <RecentPlaylistItem>[
      item,
      ...current.where((existing) => existing.id != item.id),
    ].take(_limit).toList(growable: false);

    state = AsyncData(next);
    await _writeCached(next);
  }

  Future<List<RecentPlaylistItem>> _readCached() async {
    final raw = await SafeSecureStorage.read(_storageKey);
    if (raw == null || raw.isEmpty) return const <RecentPlaylistItem>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RecentPlaylistItem.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      await SafeSecureStorage.delete(_storageKey);
      return const <RecentPlaylistItem>[];
    }
  }

  Future<void> _writeCached(List<RecentPlaylistItem> items) {
    return SafeSecureStorage.write(
      key: _storageKey,
      value: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}

final recentPlaylistsProvider =
    AsyncNotifierProvider<RecentPlaylistsNotifier, List<RecentPlaylistItem>>(
      RecentPlaylistsNotifier.new,
    );
