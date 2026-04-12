import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../../core/routing/routes.dart';
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

    // FIX: Do NOT conditionally remove/add the ChatInputBar based on keyboard
    // state — that destroys and recreates the TextField, killing focus.
    // Instead, always keep ChatInputBar in bottomNavigationBar and set
    // resizeToAvoidBottomInset: true so Flutter shifts the whole scaffold up.
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: MessagingBottomShell(
        above: ChatInputBar(
          isSending: chatState.isSending,
          onSend: (text) {
            ref
                .read(
                    chatControllerProvider(widget.conversationId).notifier)
                .sendText(text);
          },
          onAttachTap: () => _showAttachSheet(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            _ChatAppBar(
              name: widget.otherUserName,
              avatarUrl: widget.otherUserAvatar,
              onBack: () => Navigator.of(context).pop(),
              onOptionsPressed: _optionsKey,
            ),
            const Divider(height: 0.5, color: Color(0xFF1A1A1A)),

            // ── Messages ─────────────────────────────────────────────
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  : _MessageList(
                      messages: messages,
                      scrollController: _scrollController,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Key used to anchor the popup menu to the 3-dots button.
  final _optionsKey = GlobalKey();

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

  // ── Options menu (three dots) — anchored PopupMenu, NOT bottom sheet ──────

  void _showOptionsPopup() {
    final RenderBox? button =
        _optionsKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;
    final RenderBox overlay = Navigator.of(context)
        .overlay!
        .context
        .findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        _menuItem('report', Icons.flag_outlined, 'Report'),
        _menuItem('block', Icons.block_outlined, 'Block'),
        _menuItem('archive', Icons.archive_outlined, 'Archive'),
      ],
    ).then((action) {
      if (!mounted || action == null) return;
      _handleAction(action);
    });
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    final nav = Navigator.of(context);
    switch (action) {
      case 'block':
        _showBlockConfirmation(nav);
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
        _showReportConfirmation();
    }
  }

  void _showBlockConfirmation(NavigatorState nav) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Block user?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You won\'t receive messages from ${widget.otherUserName} anymore.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
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
    });
  }

  void _showReportConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted'),
        backgroundColor: Color(0xFF2A2A2A),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.name,
    this.avatarUrl,
    required this.onBack,
    required this.onOptionsPressed,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onBack;
  // The key is passed in so the parent can find the button's position for the
  // anchored popup menu.
  final GlobalKey onOptionsPressed;

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
          // FIX: Use a GlobalKey so the parent can anchor a PopupMenu to it.
          IconButton(
            key: onOptionsPressed,
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              // Trigger the popup from the ChatScreen state.
              final state = context
                  .findAncestorStateOfType<_ChatScreenState>();
              state?._showOptionsPopup();
            },
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