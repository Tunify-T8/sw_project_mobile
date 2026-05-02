import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/realtime_event.dart';
import '../providers/messaging_dependencies_provider.dart';
import '../providers/messaging_repository_provider.dart';
import '../providers/messaging_usecases_provider.dart';
import 'messages_filter.dart';

/// State for the Activity > Messages screen.
class ConversationsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<ConversationEntity> items;
  final String? error;
  final MessagesFilter filter;

  const ConversationsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.items = const [],
    this.error,
    this.filter = MessagesFilter.all,
  });

  ConversationsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<ConversationEntity>? items,
    String? error,
    bool clearError = false,
    MessagesFilter? filter,
  }) => ConversationsState(
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    items: items ?? this.items,
    error: clearError ? null : (error ?? this.error),
    filter: filter ?? this.filter,
  );

  /// The list as it should be rendered, after the active filter is applied.
  /// Archived and blocked conversations are always hidden.
  List<ConversationEntity> get visible {
    final active = items.where((c) => !c.isArchived && !c.isBlocked).toList();
    switch (filter) {
      case MessagesFilter.all:
        return active;
      case MessagesFilter.unreadOnly:
        return active.where((c) => c.unreadCount > 0).toList();
    }
  }

  int get totalUnread => items.fold(0, (sum, c) => sum + c.unreadCount);
}

class ConversationsController extends Notifier<ConversationsState> {
  StreamSubscription<RealtimeMessagingEvent>? _eventsSub;

  /// Client-side archive set — survives refresh() calls because the backend
  /// returns all conversations regardless of status. Any id in this set is
  /// treated as archived and hidden from the visible list.
  final Set<String> _localArchivedIds = {};

  /// Client-side unarchive set — conversations explicitly re-opened by the
  /// user that should appear even if the backend still says ARCHIVED.
  final Set<String> _localUnarchivedIds = {};
  final Map<String, DateTime> _localReadWatermarks = {};
  bool _loadedReadWatermarks = false;
  String? _loadedReadWatermarksUserId;

  @override
  ConversationsState build() {
    final userId = ref.watch(messagingSessionUserIdProvider);
    unawaited(_eventsSub?.cancel());
    _eventsSub = null;
    ref.onDispose(() => _eventsSub?.cancel());
    if (userId == null || userId.isEmpty) {
      return const ConversationsState();
    }
    Future.microtask(load);
    return const ConversationsState(isLoading: true);
  }

  String _readWatermarksKey(String userId) =>
      '${StorageKeys.messagingReadWatermarks}_$userId';

  /// Merges backend items with local overrides that must survive refreshes.
  List<ConversationEntity> _applyLocalOverrides(List<ConversationEntity> items) {
    return items.map((c) {
      var next = c;
      if (_localUnarchivedIds.contains(c.conversationId)) {
        next = next.copyWith(isArchived: false);
      }
      if (_localArchivedIds.contains(c.conversationId)) {
        next = next.copyWith(isArchived: true);
      }

      final readAt = _localReadWatermarks[c.conversationId];
      final lastMessageAt = c.lastMessageAt;
      if (readAt != null &&
          (lastMessageAt == null || !lastMessageAt.isAfter(readAt))) {
        next = next.copyWith(unreadCount: 0);
      }

      return next;
    }).toList();
  }

  Future<void> _ensureReadWatermarksLoaded(String userId) async {
    if (_loadedReadWatermarksUserId != userId) {
      _loadedReadWatermarks = false;
      _loadedReadWatermarksUserId = userId;
      _localReadWatermarks.clear();
    }
    if (_loadedReadWatermarks) return;
    _loadedReadWatermarks = true;

    final raw = await SafeSecureStorage.read(_readWatermarksKey(userId));
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _localReadWatermarks
        ..clear()
        ..addEntries(
          decoded.entries
              .map((entry) {
                final parsed = DateTime.tryParse(entry.value.toString());
                if (parsed == null) return null;
                return MapEntry(entry.key, parsed);
              })
              .whereType<MapEntry<String, DateTime>>(),
        );
    } catch (_) {
      await SafeSecureStorage.delete(_readWatermarksKey(userId));
    }
  }

  Future<void> _persistReadWatermarks(String userId) {
    final encoded = jsonEncode(
      _localReadWatermarks.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    );
    return SafeSecureStorage.write(
      key: _readWatermarksKey(userId),
      value: encoded,
    );
  }

  Future<void> load() async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty) {
      state = const ConversationsState();
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ensureReadWatermarksLoaded(userId);
      await ref.read(messagingRepositoryProvider).connectRealtime();
      _bindRealtime();

      final page = await ref.read(getConversationsUseCaseProvider).call();
      if (ref.read(messagingSessionUserIdProvider) != userId) return;
      state = state.copyWith(
        isLoading: false,
        items: _applyLocalOverrides(page.items),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty) return;
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      await _ensureReadWatermarksLoaded(userId);
      final page = await ref.read(getConversationsUseCaseProvider).call();
      if (ref.read(messagingSessionUserIdProvider) != userId) return;
      state = state.copyWith(
        isRefreshing: false,
        items: _applyLocalOverrides(page.items),
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setFilter(MessagesFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
  }

  Future<void> markRead(String conversationId) async {
    final userId = ref.read(messagingSessionUserIdProvider);
    DateTime? lastMessageAt;
    for (final conversation in state.items) {
      if (conversation.conversationId == conversationId) {
        lastMessageAt = conversation.lastMessageAt;
        break;
      }
    }

    if (userId != null && userId.isNotEmpty) {
      await _ensureReadWatermarksLoaded(userId);
      final now = DateTime.now();
      _localReadWatermarks[conversationId] =
          lastMessageAt != null && lastMessageAt.isAfter(now)
              ? lastMessageAt
              : now;
      unawaited(_persistReadWatermarks(userId));
    }

    // Update locally so the UI reflects the read state immediately.
    state = state.copyWith(
      items: state.items
          .map(
            (c) => c.conversationId == conversationId
                ? c.copyWith(unreadCount: 0)
                : c,
          )
          .toList(),
    );

    try {
      await ref.read(markConversationReadUseCaseProvider).call(conversationId);
    } catch (_) {
      // Keep the local read state. If the backend returns stale unread counts
      // on the next refresh, the persisted watermark will still suppress them
      // until a newer message appears.
    }
  }

  void handleLocalMessageSent(MessageEntity message) {
    final index = state.items.indexWhere(
      (c) => c.conversationId == message.conversationId,
    );
    if (index == -1) {
      unawaited(refresh());
      return;
    }

    _localUnarchivedIds.add(message.conversationId);
    _localArchivedIds.remove(message.conversationId);

    final next = [...state.items];
    next[index] = next[index].copyWith(
      lastMessagePreview: _previewFor(message),
      lastMessageAt: message.createdAt,
      unreadCount: 0,
      isArchived: false,
    );
    next.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    state = state.copyWith(items: next);
  }

  Future<void> archiveConversation(String conversationId) async {
    await ref.read(archiveConversationUseCaseProvider).call(conversationId);
    _localArchivedIds.add(conversationId);
    _localUnarchivedIds.remove(conversationId);
    // Remove immediately from visible list without waiting for refresh.
    state = state.copyWith(
      items: state.items.map((c) {
        if (c.conversationId == conversationId) return c.copyWith(isArchived: true);
        return c;
      }).toList(),
    );
  }

  void unarchiveLocally(String conversationId) {
    _localUnarchivedIds.add(conversationId);
    _localArchivedIds.remove(conversationId);
    state = state.copyWith(
      items: state.items.map((c) {
        if (c.conversationId == conversationId) return c.copyWith(isArchived: false);
        return c;
      }).toList(),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await ref.read(deleteConversationUseCaseProvider).call(conversationId);
    state = state.copyWith(
      items: state.items
          .where((c) => c.conversationId != conversationId)
          .toList(),
    );
  }

  Future<void> blockConversation(String conversationId) async {
    await ref.read(blockConversationUseCaseProvider).call(conversationId);
    await refresh();
  }

  void _bindRealtime() {
    _eventsSub?.cancel();
    _eventsSub = ref
        .read(watchRealtimeMessagingEventsUseCaseProvider)
        .call()
        .listen((event) {
          // For any meaningful realtime change, re-fetch — the mock store is
          // already updated by the time the event arrives, so this is a cheap
          // in-memory read in mock mode and a single network call in real mode.
          switch (event) {
            case MessageReceivedEvent():
            case MessageReadEvent():
            case ConversationBlockedEvent():
              refresh();
            case TypingEvent():
              break;
          }
        });
  }

  String _previewFor(MessageEntity message) {
    if (message.type == MessageType.text) {
      return (message.text ?? '').trim();
    }
    if (message.attachments.isNotEmpty) {
      final title = message.attachments.first.title.trim();
      return title.isEmpty ? 'Shared content' : 'Music: $title';
    }
    return 'Shared content';
  }
}

final conversationsControllerProvider =
    NotifierProvider<ConversationsController, ConversationsState>(
      ConversationsController.new,
    );
