import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  List<ConversationEntity> get visible {
    switch (filter) {
      case MessagesFilter.all:
        return items;
      case MessagesFilter.unreadOnly:
        return items.where((c) => c.unreadCount > 0).toList();
    }
  }

  int get totalUnread => items.fold(0, (sum, c) => sum + c.unreadCount);
}

class ConversationsController extends Notifier<ConversationsState> {
  StreamSubscription<RealtimeMessagingEvent>? _eventsSub;

  @override
  ConversationsState build() {
    final userId = ref.watch(messagingSessionUserIdProvider);
    unawaited(_eventsSub?.cancel());
    _eventsSub = null;
    ref.onDispose(() => _eventsSub?.cancel());
    if (userId == null || userId.isEmpty) {
      return const ConversationsState();
    }
    // Auto-load on first watch — every consumer gets a populated list with
    // no extra wiring at the call site.
    Future.microtask(load);
    return const ConversationsState(isLoading: true);
  }

  Future<void> load() async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty) {
      state = const ConversationsState();
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Make sure realtime events flow before we hand control back to the UI.
      await ref.read(messagingRepositoryProvider).connectRealtime();
      _bindRealtime();

      final page = await ref.read(getConversationsUseCaseProvider).call();
      if (ref.read(messagingSessionUserIdProvider) != userId) return;
      state = state.copyWith(isLoading: false, items: page.items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty) return;
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final page = await ref.read(getConversationsUseCaseProvider).call();
      if (ref.read(messagingSessionUserIdProvider) != userId) return;
      state = state.copyWith(isRefreshing: false, items: page.items);
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setFilter(MessagesFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
  }

  Future<void> markRead(String conversationId) async {
    await ref.read(markConversationReadUseCaseProvider).call(conversationId);
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
  }

  void handleLocalMessageSent(MessageEntity message) {
    final index = state.items.indexWhere(
      (c) => c.conversationId == message.conversationId,
    );
    if (index == -1) {
      unawaited(refresh());
      return;
    }

    final next = [...state.items];
    next[index] = next[index].copyWith(
      lastMessagePreview: _previewFor(message),
      lastMessageAt: message.createdAt,
      unreadCount: 0,
    );
    next.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    state = state.copyWith(items: next);
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
