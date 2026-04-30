import 'reply_entity.dart';

class RepliesPageMetaEntity {
  const RepliesPageMetaEntity({
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

class RepliesPageEntity {
  const RepliesPageEntity({
    required this.replies,
    required this.meta,
  });

  final List<ReplyEntity> replies;
  final RepliesPageMetaEntity meta;
}
