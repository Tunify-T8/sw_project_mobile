import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../state/notification_preferences_controller.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationPreferencesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : state.preferences == null
              ? const Center(
                  child: Text('Failed to load preferences',
                      style: TextStyle(color: Colors.white54)))
              : _buildContent(context, ref, state.preferences!),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferencesEntity prefs,
  ) {
    final controller =
        ref.read(notificationPreferencesControllerProvider.notifier);

    return ListView(
      children: [
        const _SectionHeader(title: 'Push Notifications'),
        _ToggleTile(
          label: 'Likes',
          value: prefs.push.trackLiked,
          onChanged: (v) => controller.togglePush('trackLiked', v),
        ),
        _ToggleTile(
          label: 'Comments',
          value: prefs.push.trackCommented,
          onChanged: (v) => controller.togglePush('trackCommented', v),
        ),
        _ToggleTile(
          label: 'Reposts',
          value: prefs.push.trackReposted,
          onChanged: (v) => controller.togglePush('trackReposted', v),
        ),
        _ToggleTile(
          label: 'New followers',
          value: prefs.push.userFollowed,
          onChanged: (v) => controller.togglePush('userFollowed', v),
        ),
        _ToggleTile(
          label: 'New releases',
          value: prefs.push.newRelease,
          onChanged: (v) => controller.togglePush('newRelease', v),
        ),
        _ToggleTile(
          label: 'Messages',
          value: prefs.push.newMessage,
          onChanged: (v) => controller.togglePush('newMessage', v),
        ),
        _ToggleTile(
          label: 'System',
          value: prefs.push.system,
          onChanged: (v) => controller.togglePush('system', v),
        ),
        _ToggleTile(
          label: 'Subscription',
          value: prefs.push.subscription,
          onChanged: (v) => controller.togglePush('subscription', v),
        ),
        const _SectionHeader(title: 'Email Notifications'),
        _ToggleTile(
          label: 'Likes',
          value: prefs.email.trackLiked,
          onChanged: (v) => controller.toggleEmail('trackLiked', v),
        ),
        _ToggleTile(
          label: 'Comments',
          value: prefs.email.trackCommented,
          onChanged: (v) => controller.toggleEmail('trackCommented', v),
        ),
        _ToggleTile(
          label: 'Reposts',
          value: prefs.email.trackReposted,
          onChanged: (v) => controller.toggleEmail('trackReposted', v),
        ),
        _ToggleTile(
          label: 'New followers',
          value: prefs.email.userFollowed,
          onChanged: (v) => controller.toggleEmail('userFollowed', v),
        ),
        _ToggleTile(
          label: 'New releases',
          value: prefs.email.newRelease,
          onChanged: (v) => controller.toggleEmail('newRelease', v),
        ),
        _ToggleTile(
          label: 'Messages',
          value: prefs.email.newMessage,
          onChanged: (v) => controller.toggleEmail('newMessage', v),
        ),
        _ToggleTile(
          label: 'System',
          value: prefs.email.system,
          onChanged: (v) => controller.toggleEmail('system', v),
        ),
        _ToggleTile(
          label: 'Subscription',
          value: prefs.email.subscription,
          onChanged: (v) => controller.toggleEmail('subscription', v),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFF3A3A3A),
      ),
    );
  }
}
