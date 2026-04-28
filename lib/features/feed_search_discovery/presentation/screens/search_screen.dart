import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../utils/search_track_playback.dart';
import '../widgets/search/search_bar_widget.dart';
import '../widgets/search/search_genre_grid.dart';
import '../widgets/search/search_typing_suggestions.dart';
import '../widgets/search/search_result_tabs.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  void _openRecentResult(RecentResultItem item) {
    switch (item.kind) {
      case RecentResultKind.track:
        final track = item.track;
        if (track != null) {
          playSearchTrack(context, ref, track);
        }
        break;
      case RecentResultKind.profile:
        navigateToProfile(
          context,
          item.id,
          currentUserId: ref.read(authControllerProvider).value?.id,
        );
        break;
      case RecentResultKind.playlist:
      case RecentResultKind.album:
        Navigator.of(
          context,
        ).pushNamed(Routes.playlistDetail, arguments: {'playlistId': item.id});
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        ref.read(searchProvider.notifier).onSearchFocused();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar — always visible
            SearchBarWidget(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchProvider.notifier).onQueryChanged(value);
              },
              onSubmitted: (value) {
                _focusNode.unfocus();
                ref.read(searchProvider.notifier).onQuerySubmitted(value);
              },
              onClear: () {
                _controller.clear();
                ref.read(searchProvider.notifier).onSearchCleared();
                _focusNode.unfocus();
              },
              onBack: state.mode != SearchScreenMode.idle
                  ? () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).onSearchDismissed();
                      _focusNode.unfocus();
                    }
                  : null,
              showBackButton: state.mode != SearchScreenMode.idle,
            ),

            // Body — switches based on mode
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (state.mode) {
                  SearchScreenMode.idle => SearchGenreGrid(
                    key: const ValueKey('idle'),
                    genres: state.genres,
                    isLoading: state.isLoadingGenres,
                  ),
                  SearchScreenMode.typing => SearchTypingSuggestions(
                    key: const ValueKey('typing'),
                    recentSearches: state.recentSearches,
                    recentResults: state.recentResults,
                    query: state.query,
                    suggestions: state.typingSuggestions,
                    onSuggestionTap: (q) {
                      _controller.text = q;
                      _focusNode.unfocus();
                      ref.read(searchProvider.notifier).onQuerySubmitted(q);
                    },
                    onRecentTap: (item) {
                      _controller.text = item.title;
                      _focusNode.unfocus();
                      _openRecentResult(item);
                    },
                    onRecentRemove: (result) {
                      ref
                          .read(searchProvider.notifier)
                          .removeRecentResult(result);
                    },
                    onClearAll: () {
                      ref.read(searchProvider.notifier).clearRecentResults();
                    },
                  ),
                  SearchScreenMode.results => SearchResultsTabs(
                    key: ValueKey('results_${state.query}'),
                    state: state,
                    onTabChanged: (tab) {
                      ref.read(searchProvider.notifier).setActiveTab(tab);
                    },
                    onLoadMore: () {
                      ref.read(searchProvider.notifier).loadMore();
                    },
                    onToggleLike: (_) {
                      // wire up engagement provider when Module 6 is ready
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
