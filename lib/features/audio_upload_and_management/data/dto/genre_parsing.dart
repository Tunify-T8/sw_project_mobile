import '../../domain/entities/upload_genre.dart';

part 'genre_parsing_helpers.dart';

class ParsedUploadGenre {
  const ParsedUploadGenre({this.normalized, this.category, this.subGenre});

  final String? normalized;
  final String? category;
  final String? subGenre;
}

ParsedUploadGenre parseUploadGenre(
  dynamic rawGenre, {
  String? fallbackCategory,
  String? fallbackSubGenre,
}) {
  final parsedFallbackCategory = _cleanString(fallbackCategory);
  final parsedFallbackSubGenre = _cleanString(fallbackSubGenre);

  if (rawGenre is Map<String, dynamic>) {
    return _normalizeGenreParts(
      rawCategory: rawGenre['category']?.toString(),
      rawSubGenre:
          (rawGenre['subGenre'] ??
                  rawGenre['subcategory'] ??
                  rawGenre['subgenre'])
              ?.toString(),
      rawLabel: rawGenre['label']?.toString(),
      fallbackCategory: parsedFallbackCategory,
      fallbackSubGenre: parsedFallbackSubGenre,
    );
  }

  final rawValue = _cleanString(rawGenre);
  if (rawValue == null) {
    return _normalizeGenreParts(
      rawCategory: parsedFallbackCategory,
      rawSubGenre: parsedFallbackSubGenre,
    );
  }

  final parts = rawValue.split('_');
  if (parts.length > 1 && _isKnownGenreGroup(parts.first)) {
    return _normalizeGenreParts(
      rawCategory: parts.first,
      rawSubGenre: parts.skip(1).join('_'),
      fallbackCategory: parsedFallbackCategory,
      fallbackSubGenre: parsedFallbackSubGenre,
      rawLabel: rawValue,
    );
  }

  return _normalizeGenreParts(
    rawCategory: parsedFallbackCategory,
    rawSubGenre: parsedFallbackSubGenre ?? rawValue,
    fallbackCategory: parsedFallbackCategory,
    fallbackSubGenre: parsedFallbackSubGenre,
    rawLabel: rawValue,
  );
}
