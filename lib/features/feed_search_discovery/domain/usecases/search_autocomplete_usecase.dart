import '../entities/autocomplete_result_entity.dart';
import '../repositories/search_repository.dart';

/// Fetches autocomplete suggestions for a partial query.
///
/// Delegates directly to [SearchRepository.searchAutocomplete].
/// Returns up to 5 results per category (tracks, users, collections).
/// Matches from a single character; typo tolerance is applied by the backend.
class SearchAutocompleteUseCase {
  const SearchAutocompleteUseCase(this._repo);

  final SearchRepository _repo;

  Future<AutocompleteResultEntity> call(String query) =>
      _repo.searchAutocomplete(query);
}
