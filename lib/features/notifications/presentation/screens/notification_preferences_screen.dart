import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../state/notification_preferences_controller.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  static const _supportedItems = [
    _PreferenceItem('Comments on your post', 'trackCommented'),
    _PreferenceItem('Likes on your post', 'trackLiked'),
    _PreferenceItem('New follower', 'userFollowed'),
    _PreferenceItem('New message', 'newMessage'),
    _PreferenceItem('New post by followed user', 'newRelease'),
    _PreferenceItem('Reposts of your post', 'trackReposted'),
    _PreferenceItem('System notifications', 'system'),
    _PreferenceItem('Subscription updates', 'subscription'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NotificationPreferencesState>(
      notificationPreferencesControllerProvider,
      (previous, next) {
        final error = next.error;
        if (error == null || error == previous?.error) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save notification setting: $error'),
          ),
        );
      },
    );

    final state = ref.watch(notificationPreferencesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: _RoundBackButton(onPressed: () => Navigator.of(context).pop()),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.onBackground,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(child: _Body(state: state)),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final NotificationPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.preferences == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final prefs = state.preferences;
    if (prefs == null) {
      return _LoadFailedView(
        onRetry: () =>
            ref.read(notificationPreferencesControllerProvider.notifier).load(),
      );
    }

    final controller = ref.read(
      notificationPreferencesControllerProvider.notifier,
    );

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          _SectionTitle(title: 'Push notifications'),
          _PreferenceGroup(
            masterLabel: 'All push notifications',
            masterValue: prefs.push.allEnabled,
            onMasterChanged: controller.setAllPush,
            channel: prefs.push,
            items: NotificationPreferencesScreen._supportedItems,
            enabled: !state.isSaving,
            onChanged: controller.togglePush,
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Email notifications'),
          _PreferenceGroup(
            masterLabel: 'All email notifications',
            masterValue: prefs.email.allEnabled,
            onMasterChanged: controller.setAllEmail,
            channel: prefs.email,
            items: NotificationPreferencesScreen._supportedItems,
            enabled: !state.isSaving,
            onChanged: controller.toggleEmail,
          ),
        ],
      ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({
    required this.masterLabel,
    required this.masterValue,
    required this.onMasterChanged,
    required this.channel,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  final String masterLabel;
  final bool masterValue;
  final ValueChanged<bool> onMasterChanged;
  final PreferenceChannel channel;
  final List<_PreferenceItem> items;
  final bool enabled;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            _ToggleRow(
              label: masterLabel,
              value: masterValue,
              enabled: enabled,
              onChanged: onMasterChanged,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 26, 24, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CUSTOMIZE SETTINGS',
                  style: TextStyle(
                    color: Color(0xFFC9C9C9),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
            for (final item in items)
              _ToggleRow(
                label: item.label,
                value: channel.valueFor(item.key),
                enabled: enabled,
                onChanged: (value) => onChanged(item.key, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 18, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? AppColors.onBackground : Colors.white54,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF4B4B4B),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 25,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: AppColors.surfaceHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.chevron_left,
              color: AppColors.onBackground,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Failed to load notification settings',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _PreferenceItem {
  const _PreferenceItem(this.label, this.key);

  final String label;
  final String key;
}

extension on PreferenceChannel {
  bool get allEnabled => toMap().values.every((value) => value);

  bool valueFor(String key) => toMap()[key] ?? true;
}
