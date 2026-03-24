import '../../domain/entities/upload_genre.dart';

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

ParsedUploadGenre _normalizeGenreParts({
  String? rawCategory,
  String? rawSubGenre,
  String? rawLabel,
  String? fallbackCategory,
  String? fallbackSubGenre,
}) {
  var category = _cleanString(rawCategory) ?? _cleanString(fallbackCategory);
  var subGenre = _cleanString(rawSubGenre) ?? _cleanString(fallbackSubGenre);
  final label = _cleanString(rawLabel);

  if (subGenre == null && label != null && !_isKnownGenreGroup(label)) {
    subGenre = label;
  }

  // Some backend responses send the chosen genre inside `category` and keep
  // `subGenre` null, e.g. { category: "country", subGenre: null }.
  if (subGenre == null && category != null && !_isKnownGenreGroup(category)) {
    subGenre = category;
    category = null;
  }

  if (subGenre != null) {
    final inferredCategoryFromSubGenre = _extractKnownGenreGroup(subGenre);
    if (inferredCategoryFromSubGenre != null) {
      category = inferredCategoryFromSubGenre;
      subGenre = _removeKnownGenrePrefix(
        subGenre,
        preferredCategory: inferredCategoryFromSubGenre,
      );
    }

    subGenre = _canonicalizeSubGenre(subGenre);
    category = _isKnownGenreGroup(category)
        ? category
        : _inferCategory(subGenre, fallback: category);
  }

  return ParsedUploadGenre(
    normalized: _buildNormalizedGenre(
      category: category,
      subGenre: subGenre,
      fallback: label,
    ),
    category: category,
    subGenre: subGenre,
  );
}

String? _cleanString(dynamic value) {
  if (value == null) return null;
  final trimmed = value.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _isKnownGenreGroup(String? value) {
  return value == UploadGenreGroup.music.name ||
      value == UploadGenreGroup.audio.name;
}

String? _extractKnownGenreGroup(String value) {
  final parts = _splitNormalizedGenreParts(value);
  if (parts.length < 2) {
    return null;
  }

  final candidate = parts.first;
  return _isKnownGenreGroup(candidate) ? candidate : null;
}

String _removeKnownGenrePrefix(String value, {String? preferredCategory}) {
  final parts = _splitNormalizedGenreParts(value);
  if (parts.length < 2) {
    return value;
  }

  final candidate = parts.first;
  if (!_isKnownGenreGroup(candidate)) {
    return value;
  }

  if (preferredCategory != null && candidate != preferredCategory) {
    return value;
  }

  return parts.skip(1).join('_');
}

List<String> _splitNormalizedGenreParts(String value) {
  return _normalizeLookup(value)
      .split('_')
      .where((part) => part.isNotEmpty)
      .toList();
}

String _inferCategory(String subGenre, {String? fallback}) {
  final knownGenre = _findKnownGenre(subGenre);
  if (knownGenre != null) {
    return knownGenre.categoryValue;
  }

  if (_isKnownGenreGroup(fallback)) {
    return fallback!;
  }

  return UploadGenreGroup.music.name;
}

String _canonicalizeSubGenre(String value) {
  final knownGenre = _findKnownGenre(value);
  if (knownGenre != null) {
    return knownGenre.subGenre;
  }

  return _normalizeLookup(value);
}

UploadGenre? _findKnownGenre(String value) {
  final candidate = _normalizeLookup(value);

  for (final genre in UploadGenres.all) {
    if (genre.isNone || genre.subGenre.isEmpty) {
      continue;
    }

    if (_normalizeLookup(genre.subGenre) == candidate ||
        _normalizeLookup(genre.label) == candidate) {
      return genre;
    }
  }

  return null;
}

String _normalizeLookup(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String? _buildNormalizedGenre({
  required String? category,
  required String? subGenre,
  String? fallback,
}) {
  if (category != null && subGenre != null) {
    return '${category}_$subGenre';
  }
  return subGenre ?? fallback ?? category;
}
