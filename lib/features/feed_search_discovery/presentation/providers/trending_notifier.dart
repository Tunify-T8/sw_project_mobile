import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'trending_provider.dart';
import 'trending_state.dart';

final trendingNotifierProvider = NotifierProvider<TrendingNotifier, TrendingState>(
  TrendingNotifier.new,
);

class TrendingNotifier extends Notifier<TrendingState> {
  @override
  TrendingState build() => TrendingState();

  Future<void> loadTrending({required String genre}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(trendingRepositoryProvider);
      final trendingItem = await repository.getTrending(genre: genre);
      state = state.copyWith(
        trending: trendingItem,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
