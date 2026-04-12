import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../../core/routing/routes.dart';
import '../state/conversations_controller.dart';
import '../state/messages_filter.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/messaging_bottom_shell.dart';

/// Activity screen with two tabs: **Notifications** (placeholder) and
/// **Messages** (conversation list).
class MessagingActivityScreen extends ConsumerStatefulWidget {
  const MessagingActivityScreen({super.key});

  @override
  ConsumerState<MessagingActivityScreen> createState() =>
      _MessagingActivityScreenState();
}

class _MessagingActivityScreenState
    extends ConsumerState<MessagingActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Start on Messages tab (index 1).
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convState = ref.watch(conversationsControllerProvider);
    final hasUnread = convState.totalUnread > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const MessagingBottomShell(),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
                  _FilterButton(
                    currentFilter: convState.filter,
                    onChanged: (f) => ref
                        .read(conversationsControllerProvider.notifier)
                        .setFilter(f),
                  ),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────────
            // FIX: Use a proper TabBar with transparent divider to remove
            // the stray default bottom border that caused the half-white bug.
            TabBar(
              controller: _tabController,
              // The orange indicator — shown only on the selected tab.
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2.5,
                ),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              // Remove the default grey divider line under the whole bar.
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF8A8A8A),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                const Tab(text: 'Notifications'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Messages'),
                      if (hasUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // ── Tab body ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Notifications placeholder
                  const Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ),
                  // Messages list
                  _MessagesList(state: convState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Messages list ────────────────────────────────────────────────────────────

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
              // Mark read immediately
              ref
                  .read(conversationsControllerProvider.notifier)
                  .markRead(convo.conversationId);
              // Navigate to chat screen
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

// ── Filter dropdown ──────────────────────────────────────────────────────────

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
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}