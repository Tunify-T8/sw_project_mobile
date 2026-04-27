import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../providers/messaging_dependencies_provider.dart';
import '../providers/messaging_repository_provider.dart';
import '../providers/messaging_usecases_provider.dart';
import 'conversations_controller.dart';

/// Marker used by the realtime socket layer when it can't yet attribute a
/// message to the current user. Chat controllers replace this with the real
/// auth user id so the UI renders the bubble on the right side.
const String kOptimisticSenderMarker = '__me__';

class ChatState {
  final bool isLoading;
  final List<MessageEntity> messages;
  final String? error;
  final bool isSending;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
    this.isSending = false,
  });

  ChatState copyWith({
    bool? isLoading,
    List<MessageEntity>? messages,
    String? error,
    bool clearError = false,
    bool? isSending,
  }) => ChatState(
    isLoading: isLoading ?? this.isLoading,
    messages: messages ?? this.messages,
    error: clearError ? null : (error ?? this.error),
    isSending: isSending ?? this.isSending,
  );
}

/// Per-conversation chat controller. Loads message history, listens to
/// realtime events, and exposes send actions for the UI.
class ChatController extends Notifier<ChatState> {
  ChatController(this._conversationId);

  final String _conversationId;
  StreamSubscription<RealtimeMessagingEvent>? _eventsSub;

  @override
  ChatState build() {
    final userId = ref.watch(messagingSessionUserIdProvider);
    unawaited(_eventsSub?.cancel());
    _eventsSub = null;
    ref.onDispose(() async {
      await _eventsSub?.cancel();
      try {
        await ref
            .read(messagingRepositoryProvider)
            .leaveConversation(_conversationId);
      } catch (_) {}
    });
    if (userId == null || userId.isEmpty || _conversationId.isEmpty) {
      return const ChatState();
    }
    Future.microtask(_bootstrap);
    return const ChatState(isLoading: true);
  }

  String? _currentUserId() => ref.read(messagingSessionUserIdProvider);

  MessageEntity _attributeToMe(MessageEntity message) {
    final me = _currentUserId();
    if (me == null || me.isEmpty) return message;
    if (message.senderId == kOptimisticSenderMarker) {
      return MessageEntity(
        id: message.id,
        conversationId: message.conversationId,
        senderId: me,
        type: message.type,
        text: message.text,
        attachments: message.attachments,
        createdAt: message.createdAt,
        isRead: message.isRead,
        isPending: message.isPending,
        isFailed: message.isFailed,
      );
    }
    return message;
  }

  MessageEntity _optimisticMessageFromDraft(SendMessageDraft draft) {
    return MessageEntity(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: _conversationId,
      senderId: _currentUserId() ?? kOptimisticSenderMarker,
      type: draft.attachments.isNotEmpty
          ? MessageType.attachment
          : MessageType.text,
      text: (draft.text ?? '').trim().isEmpty ? null : draft.text!.trim(),
      attachments: draft.attachments,
      createdAt: DateTime.now(),
      isRead: true,
      isPending: true,
    );
  }

  bool _samePayload(MessageEntity a, MessageEntity b) {
    return a.senderId == b.senderId &&
        (a.text ?? '') == (b.text ?? '') &&
        a.attachments.length == b.attachments.length &&
        a.type == b.type;
  }

  Future<void> _bootstrap() async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty || _conversationId.isEmpty) return;
    try {
      final repo = ref.read(messagingRepositoryProvider);
      await repo.connectRealtime();
      await repo.joinConversation(_conversationId);
      _bindRealtime();

      final page = await ref
          .read(getMessagesUseCaseProvider)
          .call(_conversationId);
      if (ref.read(messagingSessionUserIdProvider) != userId) return;

      // Backend returns most-recent-first — render oldest → newest.
      final chronological = [...page.items]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = state.copyWith(isLoading: false, messages: chronological);

      if (ref.read(messagingSessionUserIdProvider) == userId) {
        await ref
            .read(markConversationReadUseCaseProvider)
            .call(_conversationId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _bindRealtime() {
    _eventsSub?.cancel();
    _eventsSub = ref
        .read(watchRealtimeMessagingEventsUseCaseProvider)
        .call()
        .listen((event) {
          switch (event) {
            case MessageReceivedEvent(:final message):
              if (message.conversationId != _conversationId) return;
              final attributed = _attributeToMe(message);
              // Drop the optimistic placeholder if the canonical version arrives.
              final filtered = state.messages.where((m) {
                if (m.id == attributed.id) return false;
                if (m.isPending && m.senderId == attributed.senderId) {
                  if ((m.text ?? '') == (attributed.text ?? '') &&
                      m.attachments.length == attributed.attachments.length) {
                    return false;
                  }
                }
                return true;
              }).toList();
              state = state.copyWith(messages: [...filtered, attributed]);
              ref
                  .read(markConversationReadUseCaseProvider)
                  .call(_conversationId);
            case MessageReadEvent():
            case ConversationBlockedEvent():
            case TypingEvent():
              break;
          }
        });
  }

  Future<void> sendText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.isSending) return;
    await sendDraft(text: text, attachments: const []);
  }

  Future<void> sendAttachments(List<MessageAttachment> attachments) async {
    if (attachments.isEmpty || state.isSending) return;
    await sendDraft(text: '', attachments: attachments);
  }

  Future<void> sendDraft({
    required String text,
    required List<MessageAttachment> attachments,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && attachments.isEmpty) return;
    if (state.isSending) return;

    if (trimmedText.isNotEmpty && attachments.isNotEmpty) {
      for (final attachment in attachments) {
        if (state.isSending) return;
        await _send(
          SendMessageDraft(
            type: MessageType.attachment,
            attachments: [attachment],
          ),
        );
      }
      if (state.isSending) return;
      await _send(
        SendMessageDraft(
          type: MessageType.text,
          text: trimmedText,
          attachments: const [],
        ),
      );
      return;
    }

    if (attachments.length > 1) {
      for (final attachment in attachments) {
        if (state.isSending) return;
        await _send(
          SendMessageDraft(
            type: MessageType.attachment,
            attachments: [attachment],
          ),
        );
      }
      return;
    }

    await _send(
      SendMessageDraft(
        type: attachments.isNotEmpty
            ? MessageType.attachment
            : MessageType.text,
        text: trimmedText.isEmpty ? null : trimmedText,
        attachments: attachments,
      ),
    );
  }

  Future<void> _send(SendMessageDraft draft) async {
    final userId = ref.read(messagingSessionUserIdProvider);
    if (userId == null || userId.isEmpty) return;
    final optimistic = _optimisticMessageFromDraft(draft);
    state = state.copyWith(
      isSending: true,
      clearError: true,
      messages: [...state.messages, optimistic],
    );
    ref
        .read(conversationsControllerProvider.notifier)
        .handleLocalMessageSent(optimistic);

    try {
      final message = await ref
          .read(sendMessageUseCaseProvider)
          .call(_conversationId, draft);
      if (ref.read(messagingSessionUserIdProvider) != userId) return;

      // Sending to an archived conversation unarchives it so it reappears.
      ref
          .read(conversationsControllerProvider.notifier)
          .unarchiveLocally(_conversationId);

      final attributed = _attributeToMe(message);
      final alreadyInList = state.messages.any((m) => m.id == attributed.id);
      var didReplace = false;
      final replaced = state.messages.map((m) {
        if (m.id == optimistic.id ||
            (m.isPending && _samePayload(m, attributed))) {
          didReplace = true;
          return attributed;
        }
        return m;
      }).toList();
      state = state.copyWith(
        isSending: false,
        messages: alreadyInList
            ? state.messages
            : (didReplace ? replaced : [...state.messages, attributed]),
      );
      ref
          .read(conversationsControllerProvider.notifier)
          .handleLocalMessageSent(attributed);
    } catch (e) {
      if (ref.read(messagingSessionUserIdProvider) != userId) return;
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
        messages: state.messages
            .map(
              (m) => m.id == optimistic.id
                  ? m.copyWith(isPending: false, isFailed: true)
                  : m,
            )
            .toList(),
      );
      unawaited(ref.read(conversationsControllerProvider.notifier).refresh());
    }
  }

  Future<void> archiveConversation() async {
    await ref
        .read(conversationsControllerProvider.notifier)
        .archiveConversation(_conversationId);
  }

  Future<void> blockConversation() async {
    await ref.read(blockConversationUseCaseProvider).call(_conversationId);
  }

  Future<void> deleteConversation() async {
    await ref.read(deleteConversationUseCaseProvider).call(_conversationId);
  }
}

final chatControllerProvider =
    NotifierProvider.family<ChatController, ChatState, String>(
      (conversationId) => ChatController(conversationId),
    );
