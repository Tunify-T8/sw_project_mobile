import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../../core/utils/adaptive_breakpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../state/chat_controller.dart';
import '../state/conversations_controller.dart';
import '../utils/messaging_time_format.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_buble.dart';
import '../widgets/messaging_bottom_shell.dart';
import 'attach_content_sheet.dart';
import 'report_contact_screen.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../../../features/followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.pendingAttachment,
  });

  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;

  /// If set, the screen immediately sends this attachment once the history
  /// has loaded — used by the "Send to" row in the track options sheet.
  final MessageAttachment? pendingAttachment;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _optionsKey = GlobalKey();
  final List<MessageAttachment> _pendingAttachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.pendingAttachment != null) {
      _pendingAttachments.add(widget.pendingAttachment!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.conversationId));
    final conversation = ref.watch(
      conversationsControllerProvider.select((state) {
        for (final item in state.items) {
          if (item.conversationId == widget.conversationId) return item;
        }
        return null;
      }),
    );
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final authUserId = ref.watch(authControllerProvider).value?.id;
    final currentUserId = authUserId ?? 'me';
    final appBarName = _bestName(
      widget.otherUserName,
      conversation?.otherUser.displayName,
    );
    final appBarAvatar = _bestAvatar(
      widget.otherUserAvatar,
      conversation?.otherUser.avatarUrl,
    );

    ref.listen(chatControllerProvider(widget.conversationId), (previous, next) {
      if ((previous?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    final otherUserId = conversation?.otherUser.id ?? '';
    final relationshipIsBlocked = otherUserId.isNotEmpty
        ? ref.watch(relationshipStatusProvider(otherUserId)).isBlocked
        : null;
    final isBlocked = relationshipIsBlocked ?? conversation?.isBlocked ?? false;

    final bottomWidget = isBlocked
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  "You've blocked this account and can't send messages to them.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(relationshipStatusProvider(otherUserId).notifier)
                        .toggleBlock(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Unblock',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          )
        : ChatInputBar(
            isSending: chatState.isSending,
            pendingAttachments: _pendingAttachments,
            onRemoveAttachment: _removePendingAttachment,
            onSend: _sendComposerMessage,
            onAttachTap: () => _showAttachSheet(context),
          );

    final isDesktop = AdaptiveBreakpoints.isExpanded(context);
    if (isDesktop) {
      final chatContent = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _ChatAppBar(
              name: appBarName,
              avatarUrl: appBarAvatar,
              onBack: () => Navigator.of(context).pop(),
              optionsButtonKey: _optionsKey,
              onOptionsPressed: _showOptionsPopup,
            ),
            const Divider(height: 0.5, color: Color(0xFF1A1A1A)),
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _MessageList(
                      messages: chatState.messages,
                      scrollController: _scrollController,
                      currentUserId: currentUserId,
                    ),
            ),
            bottomWidget,
          ],
        ),
      );

      return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: keyboardOpen ? null : const MessagingBottomShell(),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: AdaptiveBreakpoints.pagePadding(context),
            child: AdaptiveCenter(
              maxWidth: 980,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF242424)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: chatContent,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: keyboardOpen ? null : const MessagingBottomShell(),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _ChatAppBar(
                name: appBarName,
                avatarUrl: appBarAvatar,
                onBack: () => Navigator.of(context).pop(),
                optionsButtonKey: _optionsKey,
                onOptionsPressed: _showOptionsPopup,
              ),
              const Divider(height: 0.5, color: Color(0xFF1A1A1A)),
              Expanded(
                child: chatState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _MessageList(
                        messages: chatState.messages,
                        scrollController: _scrollController,
                        currentUserId: currentUserId,
                      ),
              ),
              bottomWidget,
            ],
          ),
        ),
      ),
    );
  }

  String _bestName(String routeName, String? hydratedName) {
    final hydrated = hydratedName?.trim() ?? '';
    if (hydrated.isNotEmpty && hydrated != 'Unknown User') return hydrated;
    final route = routeName.trim();
    if (route.isNotEmpty && route != 'Unknown User') return route;
    return hydrated.isNotEmpty ? hydrated : 'Unknown User';
  }

  String? _bestAvatar(String? routeAvatar, String? hydratedAvatar) {
    final hydrated = hydratedAvatar?.trim() ?? '';
    if (hydrated.isNotEmpty) return hydrated;
    final route = routeAvatar?.trim() ?? '';
    return route.isEmpty ? null : route;
  }

  void _showAttachSheet(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet<List<MessageAttachment>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttachContentSheet(),
    ).then((attachments) {
      if (!mounted || attachments == null || attachments.isEmpty) return;

      setState(() {
        for (final attachment in attachments) {
          final alreadyAdded = _pendingAttachments.any(
            (pending) =>
                pending.id == attachment.id &&
                pending.backendKind == attachment.backendKind,
          );
          if (!alreadyAdded) {
            _pendingAttachments.add(attachment);
          }
        }
      });
    });
  }

  void _removePendingAttachment(MessageAttachment attachment) {
    setState(() {
      _pendingAttachments.removeWhere(
        (pending) =>
            pending.id == attachment.id &&
            pending.backendKind == attachment.backendKind,
      );
    });
  }

  void _sendComposerMessage(String text) {
    final attachments = List<MessageAttachment>.of(_pendingAttachments);
    if (text.trim().isEmpty && attachments.isEmpty) return;

    setState(_pendingAttachments.clear);
    unawaited(
      ref
          .read(chatControllerProvider(widget.conversationId).notifier)
          .sendDraft(text: text, attachments: attachments),
    );
  }

  void _showOptionsPopup() {
    final RenderBox? button =
        _optionsKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    ConversationEntity? conversation;
    for (final item in ref.read(conversationsControllerProvider).items) {
      if (item.conversationId == widget.conversationId) {
        conversation = item;
        break;
      }
    }
    final otherUserId = conversation?.otherUser.id ?? '';
    final isBlocked = otherUserId.isNotEmpty
        ? (ref.read(relationshipStatusProvider(otherUserId)).isBlocked ?? false)
        : false;

    showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        _menuItem('report', Icons.flag_outlined, 'Report'),
        _menuItem('block', Icons.block, isBlocked ? 'Unblock' : 'Block user'),
        _menuItem('archive', Icons.archive_outlined, 'Archive'),
      ],
    ).then((action) {
      if (!mounted || action == null) return;
      _handleAction(action, otherUserId: otherUserId);
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

  void _handleAction(String action, {String otherUserId = ''}) {
    switch (action) {
      case 'block':
        _showBlockConfirmation(otherUserId: otherUserId);
        break;
      case 'archive':
        _archiveConversation();
        break;
      case 'report':
        _openReportScreen();
        break;
    }
  }

  void _showBlockConfirmation({String otherUserId = ''}) {
    final isCurrentlyBlocked = otherUserId.isNotEmpty
        ? (ref.read(relationshipStatusProvider(otherUserId)).isBlocked ?? false)
        : false;

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          isCurrentlyBlocked ? 'Unblock user?' : 'Block user?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          isCurrentlyBlocked
              ? 'You\'ll be able to receive messages from ${widget.otherUserName} again.'
              : 'You won\'t receive messages from ${widget.otherUserName} anymore.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              isCurrentlyBlocked ? 'Unblock' : 'Block',
              style: TextStyle(
                color: isCurrentlyBlocked ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted || otherUserId.isEmpty) return;
      ref.read(relationshipStatusProvider(otherUserId).notifier).toggleBlock();
    });
  }

  void _archiveConversation() {
    ref
        .read(chatControllerProvider(widget.conversationId).notifier)
        .archiveConversation()
        .then((_) {
          if (!mounted) return;
          Navigator.of(context).pop();
        });
  }

  void _openReportScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportContactScreen(
          conversationId: widget.conversationId,
          otherUserName: widget.otherUserName,
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.name,
    this.avatarUrl,
    required this.onBack,
    required this.optionsButtonKey,
    required this.onOptionsPressed,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onBack;
  final GlobalKey optionsButtonKey;
  final VoidCallback onOptionsPressed;

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
            backgroundColor: Colors.blue.withValues(alpha: 0.24),
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
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
            key: optionsButtonKey,
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: onOptionsPressed,
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.scrollController,
    required this.currentUserId,
  });

  final List<MessageEntity> messages;
  final ScrollController scrollController;
  final String currentUserId;

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

    for (final message in messages) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (lastDate == null || messageDate != lastDate) {
        lastDate = messageDate;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Center(
              child: Text(
                MessagingTimeFormat.dayHeader(message.createdAt),
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

      final isMine =
          message.senderId == currentUserId ||
          message.senderId == kOptimisticSenderMarker ||
          message.senderId == 'me' ||
          message.senderId == 'mock-user-001' ||
          message.senderId == 'user_current_1';

      widgets.add(MessageBubble(message: message, isMine: isMine));
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      children: widgets,
    );
  }
}
