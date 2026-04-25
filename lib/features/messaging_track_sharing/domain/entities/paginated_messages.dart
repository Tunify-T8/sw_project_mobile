import 'message_entity.dart';

class PaginatedMessages {
  final List<MessageEntity> items;
  final int page;
  final int limit;
  final int total;
  const PaginatedMessages({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });
}
