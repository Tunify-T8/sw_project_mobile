import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../notifications/presentation/state/notification_filter.dart';
import '../../../notifications/presentation/state/notifications_controller.dart';
import '../../../notifications/presentation/widgets/notifications_tab.dart';
import '../state/conversations_controller.dart';
import '../state/messages_filter.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/messaging_bottom_shell.dart';

class MessagingActivityScreen extends ConsumerStatefulWidget {
  const MessagingActivityScreen({super.key});

  @override
  ConsumerState<MessagingActivityScreen> createState() =>
      _MessagingActivityScreenState();
}

class _MessagingActivityScreenState
    extends ConsumerState<MessagingActivityScreen> {
  int _selectedTabIndex = 0; // 0 = notifications, 1 = messages

  @override
  Widget build(BuildContext context) {
    final convState = ref.watch(conversationsControllerProvider);
    final notifState = ref.watch(notificationsControllerProvider);
    final hasUnread = convState.totalUnread > 0;
    final hasUnreadNotifs = notifState.unreadCount > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const MessagingBottomShell(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Show the appropriate filter button based on selected tab.
                  _selectedTabIndex == 0
                      ? _NotificationFilterButton(
                          currentFilter: notifState.filter,
                          onChanged: (f) => ref
                              .read(notificationsControllerProvider.notifier)
                              .setFilter(f),
                        )
                      : _FilterButton(
                          currentFilter: convState.filter,
                          onChanged: (f) => ref
                              .read(conversationsControllerProvider.notifier)
                              .setFilter(f),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _ActivityTabButton(
                    label: 'Notifications',
                    selected: _selectedTabIndex == 0,
                    showDot: hasUnreadNotifs,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _ActivityTabButton(
                    label: 'Messages',
                    selected: _selectedTabIndex == 1,
                    showDot: hasUnread,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                  ),
                ),
              ],
            ),

            Expanded(
              child: _selectedTabIndex == 0
                  ? const NotificationsTab()
                  : _MessagesList(state: convState),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTabButton extends StatelessWidget {
  const _ActivityTabButton({
    required this.label,
    required this.selected,
    required this.showDot,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: 52,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.white : Colors.transparent,
              width: 2.2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF8A8A8A),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (showDot)
                const Positioned(
                  right: -12,
                  top: -1,
                  child: _UnreadDot(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MessagesList extends ConsumerWidget {
  const _MessagesList({required this.state});

  final ConversationsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final conversations = state.visible;

    if (conversations.isEmpty) {
      return Center(
        child: Text(
          state.filter == MessagesFilter.unreadOnly
              ? 'No unread messages'
              : 'No messages yet',
          style: const TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () =>
          ref.read(conversationsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final convo = conversations[index];

          return ConversationTile(
            conversation: convo,
            onTap: () {
              ref
                  .read(conversationsControllerProvider.notifier)
                  .markRead(convo.conversationId);

              Navigator.of(context).pushNamed(
                Routes.chat,
                arguments: {
                  'conversationId': convo.conversationId,
                  'otherUserName': convo.otherUser.displayName,
                  'otherUserAvatar': convo.otherUser.avatarUrl,
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Notification filter dropdown (matches SoundCloud) ───────────────────────

class _NotificationFilterButton extends StatelessWidget {
  const _NotificationFilterButton({
    required this.currentFilter,
    required this.onChanged,
  });

  final NotificationFilter currentFilter;
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NotificationFilter>(
      icon: const Icon(Icons.tune, color: Colors.white, size: 22),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onChanged,
      itemBuilder: (_) => NotificationFilter.values.map((f) {
        final selected = f == currentFilter;
        return PopupMenuItem<NotificationFilter>(
          value: f,
          child: Row(
            children: [
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                )
              else
                const SizedBox(width: 26),
              if (f == NotificationFilter.all)
                const Icon(Icons.notifications_none,
                    color: Colors.white70, size: 18)
              else if (f == NotificationFilter.reposts)
                const Icon(Icons.repeat, color: Colors.white70, size: 18)
              else if (f == NotificationFilter.likes)
                const Icon(Icons.favorite_border,
                    color: Colors.white70, size: 18)
              else if (f == NotificationFilter.comments)
                const Icon(Icons.chat_bubble_outline,
                    color: Colors.white70, size: 18)
              else if (f == NotificationFilter.followings)
                const Icon(Icons.person_add_alt,
                    color: Colors.white70, size: 18)
              else if (f == NotificationFilter.reactions)
                const Icon(Icons.emoji_emotions_outlined,
                    color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Text(
                f.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Messages filter dropdown ────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.currentFilter,
    required this.onChanged,
  });

  final MessagesFilter currentFilter;
  final ValueChanged<MessagesFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MessagesFilter>(
      icon: const Icon(Icons.tune, color: Colors.white, size: 22),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onChanged,
      itemBuilder: (_) => MessagesFilter.values.map((f) {
        final selected = f == currentFilter;
        return PopupMenuItem<MessagesFilter>(
          value: f,
          child: Row(
            children: [
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                )
              else
                const SizedBox(width: 26),
              Text(
                f.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
