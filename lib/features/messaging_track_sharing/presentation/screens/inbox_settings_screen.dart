import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../providers/messaging_repository_provider.dart';

class _AllowAllState {
  final bool enabled;
  final bool isLoading;

  const _AllowAllState({this.enabled = false, this.isLoading = false});

  _AllowAllState copyWith({bool? enabled, bool? isLoading}) => _AllowAllState(
        enabled: enabled ?? this.enabled,
        isLoading: isLoading ?? this.isLoading,
      );
}

class _AllowAllNotifier extends Notifier<_AllowAllState> {
  @override
  _AllowAllState build() => const _AllowAllState();

  Future<void> toggle(bool enabled) async {
    final previous = state.enabled;
    state = state.copyWith(enabled: enabled, isLoading: true);
    try {
      final repo = ref.read(messagingRepositoryProvider);
      if (enabled) {
        await repo.enableReceiveFromAnyone();
      } else {
        await repo.disableReceiveFromAnyone();
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(enabled: previous, isLoading: false);
    }
  }
}

final _allowAllProvider =
    NotifierProvider<_AllowAllNotifier, _AllowAllState>(_AllowAllNotifier.new);

class InboxSettingsScreen extends ConsumerWidget {
  const InboxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_allowAllProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Inbox', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: const Text(
              'Receive messages from anyone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Switch(
              value: state.enabled,
              onChanged: state.isLoading
                  ? null
                  : (val) =>
                      ref.read(_allowAllProvider.notifier).toggle(val),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF4A4A4A),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'For your safety, we recommend only allowing messages from people you follow. Turning this on will allow anyone to send you messages',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
