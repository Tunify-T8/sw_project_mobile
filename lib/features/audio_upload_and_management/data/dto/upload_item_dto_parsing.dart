part of 'upload_item_dto.dart';

List<String> _parseArtists(Map<String, dynamic> json) {
  final list = json['artists'];
  if (list is List && list.isNotEmpty) {
    return list
        .map((e) {
          if (e is String) return e.trim();
          if (e is Map<String, dynamic>) {
            return (e['name'] ?? e['username'] ?? e['userId'] ?? '')
                .toString()
                .trim();
          }
          return e.toString().trim();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  final singular = json['artist'];
  if (singular is String && singular.trim().isNotEmpty) {
    return [singular.trim()];
  }

  if (singular is Map<String, dynamic>) {
    final value = (singular['name'] ?? singular['username'] ?? singular['id'])
        ?.toString()
        .trim();
    if (value != null && value.isNotEmpty) {
      return [value];
    }
  }

  return const [];
}

Map<String, dynamic>? _asMap(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final trimmed = value.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}
