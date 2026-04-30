import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_preferences_entity.dart';
import '../providers/notification_providers.dart';

class NotificationPreferencesState {
  final bool isLoading;
  final bool isSaving;
  final NotificationPreferencesEntity? preferences;
  final String? error;

  const NotificationPreferencesState({
    this.isLoading = false,
    this.isSaving = false,
    this.preferences,
    this.error,
  });

  NotificationPreferencesState copyWith({
    bool? isLoading,
    bool? isSaving,
    NotificationPreferencesEntity? preferences,
    String? error,
    bool clearError = false,
  }) => NotificationPreferencesState(
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    preferences: preferences ?? this.preferences,
    error: clearError ? null : (error ?? this.error),
  );
}

class NotificationPreferencesController
    extends Notifier<NotificationPreferencesState> {
  @override
  NotificationPreferencesState build() {
    Future.microtask(load);
    return const NotificationPreferencesState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final prefs = await ref
          .read(getNotificationPreferencesUseCaseProvider)
          .call();
      state = state.copyWith(isLoading: false, preferences: prefs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> togglePush(String key, bool value) => _updatePush({key: value});

  Future<void> toggleEmail(String key, bool value) =>
      _updateEmail({key: value});

  Future<void> setAllPush(bool value) => _updatePush(_allKeys(value));

  Future<void> setAllEmail(bool value) => _updateEmail(_allKeys(value));

  Future<void> _updatePush(Map<String, bool> changes) async {
    final current = state.preferences;
    if (current == null || changes.isEmpty) return;

    final nextPush = _channelWithChanges(current.push, changes);
    state = state.copyWith(
      isSaving: true,
      preferences: current.copyWith(push: nextPush),
      clearError: true,
    );

    try {
      await ref
          .read(updateNotificationPreferencesUseCaseProvider)
          .call(push: changes);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        preferences: current,
        error: e.toString(),
      );
    }
  }

  Future<void> _updateEmail(Map<String, bool> changes) async {
    final current = state.preferences;
    if (current == null || changes.isEmpty) return;

    final nextEmail = _channelWithChanges(current.email, changes);
    state = state.copyWith(
      isSaving: true,
      preferences: current.copyWith(email: nextEmail),
      clearError: true,
    );

    try {
      await ref
          .read(updateNotificationPreferencesUseCaseProvider)
          .call(email: changes);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        preferences: current,
        error: e.toString(),
      );
    }
  }

  Map<String, bool> _allKeys(bool value) => {
    'trackLiked': value,
    'trackCommented': value,
    'trackReposted': value,
    'userFollowed': value,
    'newRelease': value,
    'newMessage': value,
    'system': value,
    'subscription': value,
  };

  PreferenceChannel _channelWithChanges(
    PreferenceChannel channel,
    Map<String, bool> changes,
  ) {
    final updated = Map<String, bool>.from(channel.toMap())..addAll(changes);
    return PreferenceChannel(
      trackLiked: updated['trackLiked'] ?? true,
      trackCommented: updated['trackCommented'] ?? true,
      trackReposted: updated['trackReposted'] ?? true,
      userFollowed: updated['userFollowed'] ?? true,
      newRelease: updated['newRelease'] ?? true,
      newMessage: updated['newMessage'] ?? true,
      system: updated['system'] ?? true,
      subscription: updated['subscription'] ?? true,
    );
  }
}

final notificationPreferencesControllerProvider =
    NotifierProvider<
      NotificationPreferencesController,
      NotificationPreferencesState
    >(NotificationPreferencesController.new);
