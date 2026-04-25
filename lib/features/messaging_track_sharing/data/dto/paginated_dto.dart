/// Shared shape for `{items, page, limit, total}` responses in Module 9.
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
    final list = (j['items'] as List?) ?? const [];
    return PaginatedDto(
      items: list
          .whereType<Map<String, dynamic>>()
          .map(itemFromJson)
          .toList(),
      page: (j['page'] as int?) ?? 1,
      limit: (j['limit'] as int?) ?? list.length,
      total: (j['total'] as int?) ?? list.length,
    );
  }
}
