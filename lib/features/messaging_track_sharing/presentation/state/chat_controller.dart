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
  final Set<String> typingUserIds;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
    this.isSending = false,
    this.typingUserIds = const {},
  });

  ChatState copyWith({
    bool? isLoading,
    List<MessageEntity>? messages,
    String? error,
    bool clearError = false,
    bool? isSending,
    Set<String>? typingUserIds,
  }) => ChatState(
    isLoading: isLoading ?? this.isLoading,
    messages: messages ?? this.messages,
    error: clearError ? null : (error ?? this.error),
    isSending: isSending ?? this.isSending,
    typingUserIds: typingUserIds ?? this.typingUserIds,
  );
}

/// Per-conversation chat controller. Loads message history, listens to
/// realtime events, and exposes send actions for the UI.
class ChatController extends Notifier<ChatState> {
  ChatController(this._conversationId);

  final String _conversationId;
  StreamSubscription<RealtimeMessagingEvent>? _eventsSub;
  final Map<String, Timer> _typingTimeouts = {};
  final Set<String> _deliveredMessageIds = {};
  final Set<String> _readMessageIds = {};
  final Map<String, MessageDeliveryStatus> _pendingStatusesByMessageId = {};
  Timer? _outgoingTypingTimer;
  bool _isTypingOutgoing = false;

  @override
  ChatState build() {
    final userId = ref.watch(messagingSessionUserIdProvider);
    unawaited(_eventsSub?.cancel());
    _eventsSub = null;
    ref.onDispose(() async {
      await _eventsSub?.cancel();
      try {
        _stopOutgoingTyping();
        for (final timer in _typingTimeouts.values) {
          timer.cancel();
        }
        _typingTimeouts.clear();
        await ref
            .read(messagingRepositoryProvider)
            .leaveConversation(_conversationId);
      } catch (_) {}
      // Re-sync conversation list so the unarchived state is reflected.
      try {
        ref.read(conversationsControllerProvider.notifier).refresh();
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
        deliveryStatus: message.deliveryStatus,
        isPending: message.isPending,
        isFailed: message.isFailed,
      );
    }
    return message;
  }

  MessageEntity _normalizeOutgoingPayloadStatus(MessageEntity message) {
    if (!_isMine(message)) return message;
    final targetedStatus = _pendingStatusesByMessageId[message.id];
    if (targetedStatus != null) return message;
    if (message.deliveryStatus == MessageDeliveryStatus.notDelivered) {
      return message;
    }
    return message.copyWith(
      deliveryStatus: MessageDeliveryStatus.sent,
      isRead: false,
    );
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
      deliveryStatus: MessageDeliveryStatus.sent,
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
      // Keep the conversation visible locally while this chat is open. Sending
      // a real message persists the unarchive state on the backend.
      ref
          .read(conversationsControllerProvider.notifier)
          .unarchiveLocally(_conversationId);
      _bindRealtime();

      final page = await ref
          .read(getMessagesUseCaseProvider)
          .call(_conversationId);
      if (ref.read(messagingSessionUserIdProvider) != userId) return;

      // Backend returns most-recent-first — render oldest → newest.
      final chronological = [...page.items]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = state.copyWith(isLoading: false, messages: chronological);
      _markIncomingMessagesVisible(chronological);

      if (ref.read(messagingSessionUserIdProvider) == userId) {
        await ref
            .read(conversationsControllerProvider.notifier)
            .markRead(_conversationId);
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
              final attributed = _withPendingDeliveryStatus(
                _normalizeOutgoingPayloadStatus(_attributeToMe(message)),
                outgoingServerEcho: true,
              );
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
              _markIncomingMessagesVisible([attributed]);
              unawaited(
                ref
                    .read(conversationsControllerProvider.notifier)
                    .markRead(_conversationId),
              );
            case MessageDeliveredEvent(
              :final conversationId,
              :final messageId,
              :final readerUserId,
            ):
              if (conversationId != _conversationId) return;
              if (readerUserId.isNotEmpty && readerUserId == _currentUserId()) {
                return;
              }
              _applyDeliveryStatus(messageId, MessageDeliveryStatus.delivered);
            case MessageReadEvent(
              :final conversationId,
              :final messageId,
              :final readerUserId,
            ):
              if (conversationId != _conversationId) return;
              if (readerUserId.isNotEmpty && readerUserId == _currentUserId()) {
                return;
              }
              _applyDeliveryStatus(messageId, MessageDeliveryStatus.read);
            case MessageUndeliveredEvent(
              :final conversationId,
              :final messageId,
            ):
              if (conversationId != _conversationId) return;
              _applyDeliveryStatus(
                messageId,
                MessageDeliveryStatus.notDelivered,
              );
            case ConversationBlockedEvent():
              break;
            case TypingEvent(
              :final conversationId,
              :final userId,
              :final isTyping,
            ):
              if (conversationId != _conversationId) return;
              _applyTyping(userId, isTyping);
              break;
          }
        });
  }

  bool _isMine(MessageEntity message) {
    final me = _currentUserId();
    if (me == null || me.isEmpty) return false;
    return message.senderId == me ||
        message.senderId == kOptimisticSenderMarker;
  }

  void _markIncomingMessagesVisible(List<MessageEntity> messages) {
    for (final message in messages) {
      if (_isMine(message)) continue;
      if (message.id.isEmpty || message.id.startsWith('local_')) continue;
      if (_deliveredMessageIds.add(message.id)) {
        unawaited(
          ref
              .read(messagingRepositoryProvider)
              .markMessageDelivered(
                conversationId: _conversationId,
                messageId: message.id,
              ),
        );
      }
      if (_readMessageIds.add(message.id)) {
        unawaited(
          ref
              .read(messagingRepositoryProvider)
              .markMessageRead(
                conversationId: _conversationId,
                messageId: message.id,
              ),
        );
      }
    }
  }

  void _applyDeliveryStatus(
    String? messageId,
    MessageDeliveryStatus deliveryStatus,
  ) {
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    final hasMessage = state.messages.any(
      (message) => _isMine(message) && message.id == messageId,
    );
    if (!hasMessage && deliveryStatus == MessageDeliveryStatus.read) {
      return;
    }

    final cached = _pendingStatusesByMessageId[messageId];
    if (cached == null || _statusRank(cached) <= _statusRank(deliveryStatus)) {
      _pendingStatusesByMessageId[messageId] = deliveryStatus;
    }

    var changed = false;
    final updated = state.messages.map((message) {
      if (!_isMine(message)) return message;
      if (message.id != messageId) {
        return message;
      }
      if (_statusRank(message.deliveryStatus) > _statusRank(deliveryStatus)) {
        return message;
      }
      changed = true;
      return message.copyWith(
        deliveryStatus: deliveryStatus,
        isRead: deliveryStatus == MessageDeliveryStatus.read,
      );
    }).toList();
    if (changed) state = state.copyWith(messages: updated);
  }

  MessageEntity _withPendingDeliveryStatus(
    MessageEntity message, {
    bool outgoingServerEcho = false,
  }) {
    final status = _pendingStatusesByMessageId[message.id];
    if (status == null) {
      if (outgoingServerEcho && _isMine(message)) {
        return message.copyWith(
          deliveryStatus: MessageDeliveryStatus.sent,
          isRead: false,
        );
      }
      return message;
    }
    if (_statusRank(message.deliveryStatus) > _statusRank(status)) {
      return message;
    }
    return message.copyWith(
      deliveryStatus: status,
      isRead: status == MessageDeliveryStatus.read,
    );
  }

  int _statusRank(MessageDeliveryStatus status) {
    switch (status) {
      case MessageDeliveryStatus.sent:
        return 0;
      case MessageDeliveryStatus.notDelivered:
        return 0;
      case MessageDeliveryStatus.delivered:
        return 1;
      case MessageDeliveryStatus.read:
        return 2;
    }
  }

  void _applyTyping(String userId, bool isTyping) {
    final me = _currentUserId();
    if (userId.isEmpty || userId == me) return;

    _typingTimeouts.remove(userId)?.cancel();
    final next = Set<String>.of(state.typingUserIds);
    if (isTyping) {
      next.add(userId);
      _typingTimeouts[userId] = Timer(const Duration(seconds: 4), () {
        final remaining = Set<String>.of(state.typingUserIds)..remove(userId);
        state = state.copyWith(typingUserIds: remaining);
      });
    } else {
      next.remove(userId);
    }
    state = state.copyWith(typingUserIds: next);
  }

  void handleComposerTextChanged(String raw) {
    final hasText = raw.trim().isNotEmpty;
    if (!hasText) {
      _stopOutgoingTyping();
      return;
    }

    final repo = ref.read(messagingRepositoryProvider);
    if (!_isTypingOutgoing) {
      _isTypingOutgoing = true;
      repo.startTyping(_conversationId);
    }
    _outgoingTypingTimer?.cancel();
    _outgoingTypingTimer = Timer(
      const Duration(milliseconds: 1400),
      _stopOutgoingTyping,
    );
  }

  void handleComposerFocusChanged(bool hasFocus) {
    if (!hasFocus) _stopOutgoingTyping();
  }

  void _stopOutgoingTyping() {
    _outgoingTypingTimer?.cancel();
    _outgoingTypingTimer = null;
    if (!_isTypingOutgoing) return;
    _isTypingOutgoing = false;
    ref.read(messagingRepositoryProvider).stopTyping(_conversationId);
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
    _stopOutgoingTyping();

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
      await ref
          .read(messagingRepositoryProvider)
          .unarchiveConversation(_conversationId);
      if (ref.read(messagingSessionUserIdProvider) != userId) return;

      final attributed = _withPendingDeliveryStatus(
        _normalizeOutgoingPayloadStatus(_attributeToMe(message)),
        outgoingServerEcho: true,
      );
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
