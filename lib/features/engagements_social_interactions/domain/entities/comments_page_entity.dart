import 'comment_entity.dart';

class CommentsPageMetaEntity {
  const CommentsPageMetaEntity({
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
}

class CommentsPageEntity {
  const CommentsPageEntity({
    required this.comments,
    required this.meta,
  });

  final List<CommentEntity> comments;
  final CommentsPageMetaEntity meta;
}
