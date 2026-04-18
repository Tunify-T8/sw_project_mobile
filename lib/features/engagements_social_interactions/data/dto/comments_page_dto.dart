import 'comment_dto.dart';

class CommentsPageMetaDto {
  const CommentsPageMetaDto({
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    this.limit,
    this.hasPreviousPage,
  });

  final int totalCount;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final int? limit;
  final bool? hasPreviousPage;

  factory CommentsPageMetaDto.fromJson(Map<String, dynamic> json) {
    return CommentsPageMetaDto(
      totalCount: (json['totalCount'] as int?) ?? 0,
      page: (json['page'] as int?) ?? 1,
      totalPages: (json['totalPages'] as int?) ?? 1,
      hasNextPage: (json['hasNextPage'] as bool?) ?? false,
      limit: json['limit'] as int?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'page': page,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'limit': limit,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}

class CommentsPageDto {
  const CommentsPageDto({
    required this.comments,
    required this.meta,
  });

  final List<CommentDto> comments;
  final CommentsPageMetaDto meta;

  factory CommentsPageDto.fromJson(Map<String, dynamic> json) {
    final commentsJson = (json['comments'] as List<dynamic>?) ?? const [];
    final rootPage = (json['page'] as int?) ?? 1;
    final rootTotalCount = (json['totalCount'] as int?) ?? commentsJson.length;
    final rootTotalPages = (json['totalPages'] as int?) ?? 1;
    final rootHasNextPage = (json['hasNextPage'] as bool?) ?? false;
    final rootLimit = json['limit'] as int?;
    final rootHasPreviousPage = json['hasPreviousPage'] as bool?;

    final metaJson = (json['meta'] as Map<String, dynamic>?) ??
        <String, dynamic>{
          'totalCount': rootTotalCount,
          'page': rootPage,
          'totalPages': rootTotalPages,
          'hasNextPage': rootHasNextPage,
          'limit': rootLimit,
          'hasPreviousPage': rootHasPreviousPage,
        };

    return CommentsPageDto(
      comments: commentsJson
          .whereType<Map<String, dynamic>>()
          .map(CommentDto.fromJson)
          .toList(),
      meta: CommentsPageMetaDto.fromJson(metaJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comments': comments.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
