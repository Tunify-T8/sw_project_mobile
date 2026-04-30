/// Generic paginated envelope matching the API's standard pagination shape:
/// { data: [...], total, page, limit, hasMore }
class PaginatedDto<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedDto({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PaginatedDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final raw = json['data'] as List<dynamic>? ?? [];
    final data = raw
        .whereType<Map<String, dynamic>>()
        .map(fromJsonItem)
        .toList();
    return PaginatedDto(
      items: data,
      total: (json['total'] as num?)?.toInt() ?? data.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? data.length,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
