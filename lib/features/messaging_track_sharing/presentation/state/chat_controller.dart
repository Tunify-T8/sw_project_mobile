import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../providers/messaging_repository_provider.dart';
import '../providers/messaging_usecases_provider.dart';

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
  }) =>
      ChatState(
        isLoading: isLoading ?? this.isLoading,
        messages: messages ?? this.messages,
        error: clearError ? null : (error ?? this.error),
        isSending: isSending ?? this.isSending,
      );
}

/// Per-conversation chat controller. Loads the message history, listens to
/// realtime events, and exposes send actions for the UI.
class ChatController extends Notifier<ChatState> {
  ChatController(this._conversationId);

  final String _conversationId;
  StreamSubscription<RealtimeMessagingEvent>? _eventsSub;

  @override
  ChatState build() {
    ref.onDispose(() => _eventsSub?.cancel());
    Future.microtask(_bootstrap);
    return const ChatState(isLoading: true);
  }

  Future<void> _bootstrap() async {
    try {
      await ref.read(messagingRepositoryProvider).connectRealtime();
      _bindRealtime();

      final page = await ref
          .read(getMessagesUseCaseProvider)
          .call(_conversationId);
      state = state.copyWith(
        isLoading: false,
        messages: page.items,
      );

      // Mark the conversation as read once messages are visible.
      await ref
          .read(markConversationReadUseCaseProvider)
          .call(_conversationId);
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
          // Skip duplicates of optimistic sends.
          if (state.messages.any((m) => m.id == message.id)) return;
          state = state.copyWith(
            messages: [...state.messages, message],
          );
          // We're actively viewing this conversation — keep it read.
          ref
              .read(markConversationReadUseCaseProvider)
              .call(_conversationId);
        case MessageReadEvent():
        case ConversationBlockedEvent():
      }
    });
  }

  Future<void> sendText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.isSending) return;
    await _send(SendMessageDraft(type: MessageType.text, text: text));
  }

  Future<void> sendAttachments(List<MessageAttachment> attachments) async {
    if (attachments.isEmpty || state.isSending) return;
    await _send(
      SendMessageDraft(
        type: MessageType.attachment,
        attachments: attachments,
      ),
    );
  }

  Future<void> _send(SendMessageDraft draft) async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      await ref
          .read(sendMessageUseCaseProvider)
          .call(_conversationId, draft);
      // The repo emits a MessageReceivedEvent which the realtime listener
      // appends — no need to mutate state ourselves.
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> blockConversation() async {
    await ref
        .read(blockConversationUseCaseProvider)
        .call(_conversationId);
  }

  Future<void> deleteConversation() async {
    await ref
        .read(deleteConversationUseCaseProvider)
        .call(_conversationId);
  }
}

final chatControllerProvider =
    NotifierProvider.family<ChatController, ChatState, String>(
  (conversationId) => ChatController(conversationId),
);
