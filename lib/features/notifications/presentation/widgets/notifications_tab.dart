import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../state/notification_filter.dart';
import '../state/notifications_controller.dart';
import '../utils/notification_navigation.dart';
import '../utils/time_ago.dart';
import 'notification_empty_state.dart';
import 'notification_tile.dart';

/// The full content of the Notifications tab inside the Activity screen.
class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key});

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab> {
  bool _clearedInitialUnread = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    _clearInitialUnreadWhenVisible(state);

    if (state.items.isEmpty) {
      return NotificationEmptyState(
        filter: state.filter,
        onShowAll: () => ref
            .read(notificationsControllerProvider.notifier)
            .setFilter(NotificationFilter.all),
      );
    }

    // Group notifications by date section.
    final sections = _groupByDate(state.items);

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () =>
          ref.read(notificationsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _totalItemCount(sections),
        itemBuilder: (context, index) {
          final item = _itemAtIndex(sections, index);
          if (item is String) {
            // Section header
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final notification = item as NotificationEntity;
          return NotificationTile(
            notification: notification,
            onTap: () =>
                NotificationNavigation.openDefault(context, ref, notification),
            onActorTap: () =>
                NotificationNavigation.openActor(context, ref, notification),
            onReferenceTap: () =>
                notification.type == NotificationType.userFollowed
                ? NotificationNavigation.openActor(context, ref, notification)
                : NotificationNavigation.openReference(
                    context,
                    ref,
                    notification,
                  ),
            onActionTap: () =>
                NotificationNavigation.openActor(context, ref, notification),
          );
        },
      ),
    );
  }

  void _clearInitialUnreadWhenVisible(NotificationsState state) {
    if (_clearedInitialUnread || state.unreadCount == 0) return;
    _clearedInitialUnread = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_markInitialUnreadAsRead());
    });
  }

  Future<void> _markInitialUnreadAsRead() async {
    try {
      await ref.read(notificationsControllerProvider.notifier).markAllAsRead();
    } catch (_) {
      _clearedInitialUnread = false;
    }
  }

  /// Groups notifications into date sections: Today, Yesterday, This Week, etc.
  List<_Section> _groupByDate(List<NotificationEntity> items) {
    final Map<String, List<NotificationEntity>> groups = {};

    for (final item in items) {
      final header = dateSectionHeader(item.createdAt);
      groups.putIfAbsent(header, () => []).add(item);
    }

    return groups.entries
        .map((e) => _Section(header: e.key, items: e.value))
        .toList();
  }

  int _totalItemCount(List<_Section> sections) {
    int count = 0;
    for (final section in sections) {
      count += 1 + section.items.length; // header + items
    }
    return count;
  }

  dynamic _itemAtIndex(List<_Section> sections, int index) {
    int cursor = 0;
    for (final section in sections) {
      if (index == cursor) return section.header;
      cursor++;
      if (index < cursor + section.items.length) {
        return section.items[index - cursor];
      }
      cursor += section.items.length;
    }
    return '';
  }
}

class _Section {
  final String header;
  final List<NotificationEntity> items;
  const _Section({required this.header, required this.items});
}
