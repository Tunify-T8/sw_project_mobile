// lib/features/feed_search_discovery/presentation/screens/search_screen.dart
//
// Single screen that manages 3 modes via SearchScreenMode:
//   idle    → search bar + genre grid
//   typing  → search bar focused + recent searches + suggestion hint
//   results → tabbed results (All / Tracks / Profiles / Playlists / Albums)
//
// No results state is a widget inside results mode, not a separate screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
import '../widgets/search/search_bar_widget.dart';
import '../widgets/search/search_genre_grid.dart';
import '../widgets/search/search_typing_suggestions.dart';
import '../widgets/search/search_result_tabs.dart';
import 'genre_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

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
            // ── Search bar — always visible ───────────────────────────
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

            // ── Body — switches based on mode ─────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (state.mode) {
                  SearchScreenMode.idle => SearchGenreGrid(
                    key: const ValueKey('idle'),
                    genres: state.genres,
                    isLoading: state.isLoadingGenres,
                    onGenreTap: (genre) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GenreDetailScreen(
                            genreId: genre.id,
                            genreLabel: genre.label,
                          ),
                        ),
                      );
                    },
                  ),
                  SearchScreenMode.typing => SearchTypingSuggestions(
                    key: const ValueKey('typing'),
                    recentSearches: state.recentSearches,
                    query: state.query,
                    onRecentTap: (q) {
                      _controller.text = q;
                      _focusNode.unfocus();
                      ref.read(searchProvider.notifier).onRecentSearchTapped(q);
                    },
                    onRecentRemove: (q) {
                      ref.read(searchProvider.notifier).removeRecentSearch(q);
                    },
                    onClearAll: () {
                      ref.read(searchProvider.notifier).clearRecentSearches();
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
                    onApplyTrackFilters: (filters) {
                      ref
                          .read(searchProvider.notifier)
                          .applyTrackFilters(filters);
                    },
                    onApplyCollectionFilters: (filters) {
                      ref
                          .read(searchProvider.notifier)
                          .applyCollectionFilters(filters);
                    },
                    onApplyPeopleFilters: (filters) {
                      ref
                          .read(searchProvider.notifier)
                          .applyPeopleFilters(filters);
                    },
                    onClearFilters: () {
                      ref
                          .read(searchProvider.notifier)
                          .clearFiltersForActiveTab();
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
