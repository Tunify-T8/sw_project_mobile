import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../state/chat_controller.dart';
import '../state/conversations_controller.dart';
import '../utils/messaging_time_format.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_buble.dart';
import '../widgets/messaging_bottom_shell.dart';
import 'attach_content_sheet.dart';

/// Full-screen 1-on-1 chat view.
///
/// Layout:
/// ┌──────── App bar ────────────┐
/// │  ← avatar  Name        ··· │
/// ├─────────────────────────────┤
/// │      Date separator         │
/// │  [bubble]  [bubble]         │
/// │            [bubble] [time]  │
/// ├─────────────────────────────┤
/// │  + | Type your message… | ▸ │
/// │  MiniPlayer                 │
/// │  BottomNavBar               │
/// └─────────────────────────────┘
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.conversationId));
    final messages = chatState.messages;

    // Auto-scroll when new messages arrive.
    ref.listen(chatControllerProvider(widget.conversationId), (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 40;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: keyboardOpen
          ? null
          : MessagingBottomShell(
              above: ChatInputBar(
                isSending: chatState.isSending,
                onSend: (text) {
                  ref
                      .read(chatControllerProvider(widget.conversationId)
                          .notifier)
                      .sendText(text);
                },
                onAttachTap: () => _showAttachSheet(context),
              ),
            ),
      body: SafeArea(
        bottom: keyboardOpen,
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            _ChatAppBar(
              name: widget.otherUserName,
              avatarUrl: widget.otherUserAvatar,
              onBack: () => Navigator.of(context).pop(),
              onOptions: () => _showOptionsMenu(context),
            ),
            const Divider(height: 0.5, color: Color(0xFF1A1A1A)),

            // ── Messages ─────────────────────────────────────────────
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _MessageList(
                      messages: messages,
                      scrollController: _scrollController,
                    ),
            ),

            // When keyboard is open, show only the input bar inline.
            if (keyboardOpen)
              ChatInputBar(
                isSending: chatState.isSending,
                onSend: (text) {
                  ref
                      .read(chatControllerProvider(widget.conversationId)
                          .notifier)
                      .sendText(text);
                },
                onAttachTap: () => _showAttachSheet(context),
              ),
          ],
        ),
      ),
    );
  }

  // ── Attach content sheet ─────────────────────────────────────────────────

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet<List<MessageAttachment>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttachContentSheet(),
    ).then((attachments) {
      if (attachments != null && attachments.isNotEmpty && mounted) {
        ref
            .read(chatControllerProvider(widget.conversationId).notifier)
            .sendAttachments(attachments);
      }
    });
  }

  // ── Options menu (three dots) ────────────────────────────────────────────

  void _showOptionsMenu(BuildContext context) {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.flag_outlined,
              label: 'Report',
              onTap: () => Navigator.pop(context, 'report'),
            ),
            _OptionTile(
              icon: Icons.block,
              label: 'Block',
              onTap: () => Navigator.pop(context, 'block'),
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              label: 'Archive',
              onTap: () => Navigator.pop(context, 'archive'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).then((action) {
      if (!mounted || action == null) return;
      switch (action) {
        case 'block':
          ref
              .read(chatControllerProvider(widget.conversationId).notifier)
              .blockConversation()
              .then((_) {
            if (mounted) {
              ref
                  .read(conversationsControllerProvider.notifier)
                  .refresh();
              nav.pop();
            }
          });
        case 'archive':
          ref
              .read(chatControllerProvider(widget.conversationId).notifier)
              .deleteConversation()
              .then((_) {
            if (mounted) {
              ref
                  .read(conversationsControllerProvider.notifier)
                  .refresh();
              nav.pop();
            }
          });
        case 'report':
          messenger.showSnackBar(
            const SnackBar(content: Text('Report submitted')),
          );
      }
    });
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.name,
    this.avatarUrl,
    required this.onBack,
    required this.onOptions,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onBack;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.3),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Color(0xFF64B5F6), size: 22)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: onOptions,
          ),
        ],
      ),
    );
  }
}

// ── Message list with date separators ────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.scrollController,
  });

  final List<MessageEntity> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Say hi!',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    final widgets = <Widget>[];
    DateTime? lastDate;

    for (final msg in messages) {
      final msgDate = DateTime(
        msg.createdAt.year,
        msg.createdAt.month,
        msg.createdAt.day,
      );
      if (lastDate == null || msgDate != lastDate) {
        lastDate = msgDate;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Center(
              child: Text(
                MessagingTimeFormat.dayHeader(msg.createdAt),
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }
      final isMine = msg.senderId == 'me';
      widgets.add(MessageBubble(message: msg, isMine: isMine));
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      children: widgets,
    );
  }
}

// ── Option tile in the bottom sheet ──────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
