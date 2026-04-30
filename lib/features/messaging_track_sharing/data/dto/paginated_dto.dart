/// Shared shape for paginated responses in Module 9.
///
/// The backend returns:
///   { page, limit, total, totalPages, hasNextPage, hasPreviousPage, data: [...] }
///
/// Older mock fixtures used `items` for the list field — both are accepted.
class PaginatedDto<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  const PaginatedDto({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedDto.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final raw =
        (j['data'] as List?) ??
        (j['items'] as List?) ??
        (j['results'] as List?) ??
        (j['conversations'] as List?) ??
        (j['messages'] as List?) ??
        const [];
    final list = raw
        .whereType<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList();
    return PaginatedDto(
      items: list,
      page: (j['page'] as int?) ?? 1,
      limit: (j['limit'] as int?) ?? list.length,
      total: (j['total'] as int?) ?? (j['count'] as int?) ?? list.length,
    );
  }
}
