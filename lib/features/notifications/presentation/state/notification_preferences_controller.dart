import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_preferences_entity.dart';
import '../providers/notification_providers.dart';

class NotificationPreferencesState {
  final bool isLoading;
  final NotificationPreferencesEntity? preferences;
  final String? error;

  const NotificationPreferencesState({
    this.isLoading = false,
    this.preferences,
    this.error,
  });

  NotificationPreferencesState copyWith({
    bool? isLoading,
    NotificationPreferencesEntity? preferences,
    String? error,
    bool clearError = false,
  }) =>
      NotificationPreferencesState(
        isLoading: isLoading ?? this.isLoading,
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
      final prefs =
          await ref.read(getNotificationPreferencesUseCaseProvider).call();
      state = state.copyWith(isLoading: false, preferences: prefs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> togglePush(String key, bool value) async {
    final current = state.preferences;
    if (current == null) return;

    try {
      await ref
          .read(updateNotificationPreferencesUseCaseProvider)
          .call(push: {key: value});

      final updatedMap = Map<String, bool>.from(current.push.toMap());
      updatedMap[key] = value;

      state = state.copyWith(
        preferences: current.copyWith(
          push: PreferenceChannel(
            trackLiked: updatedMap['trackLiked'] ?? true,
            trackCommented: updatedMap['trackCommented'] ?? true,
            trackReposted: updatedMap['trackReposted'] ?? true,
            userFollowed: updatedMap['userFollowed'] ?? true,
            newRelease: updatedMap['newRelease'] ?? true,
            newMessage: updatedMap['newMessage'] ?? true,
            system: updatedMap['system'] ?? true,
            subscription: updatedMap['subscription'] ?? true,
          ),
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleEmail(String key, bool value) async {
    final current = state.preferences;
    if (current == null) return;

    try {
      await ref
          .read(updateNotificationPreferencesUseCaseProvider)
          .call(email: {key: value});

      final updatedMap = Map<String, bool>.from(current.email.toMap());
      updatedMap[key] = value;

      state = state.copyWith(
        preferences: current.copyWith(
          email: PreferenceChannel(
            trackLiked: updatedMap['trackLiked'] ?? true,
            trackCommented: updatedMap['trackCommented'] ?? true,
            trackReposted: updatedMap['trackReposted'] ?? true,
            userFollowed: updatedMap['userFollowed'] ?? true,
            newRelease: updatedMap['newRelease'] ?? true,
            newMessage: updatedMap['newMessage'] ?? true,
            system: updatedMap['system'] ?? true,
            subscription: updatedMap['subscription'] ?? true,
          ),
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationPreferencesControllerProvider = NotifierProvider<
    NotificationPreferencesController, NotificationPreferencesState>(
  NotificationPreferencesController.new,
);
