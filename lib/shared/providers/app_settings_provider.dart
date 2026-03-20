import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettingsState {
  const AppSettingsState({
    this.autoplayRelatedTracks = true,
    this.useClassicFeed = false,
  });

  final bool autoplayRelatedTracks;
  final bool useClassicFeed;

  AppSettingsState copyWith({
    bool? autoplayRelatedTracks,
    bool? useClassicFeed,
  }) {
    return AppSettingsState(
      autoplayRelatedTracks:
          autoplayRelatedTracks ?? this.autoplayRelatedTracks,
      useClassicFeed: useClassicFeed ?? this.useClassicFeed,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() => const AppSettingsState();

  void setAutoplayRelatedTracks(bool value) {
    state = state.copyWith(autoplayRelatedTracks: value);
  }

  void setUseClassicFeed(bool value) {
    state = state.copyWith(useClassicFeed: value);
  }
}
