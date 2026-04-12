import 'conversation_entity.dart';

class PaginatedConversations {
  final List<ConversationEntity> items;
  final int page;
  final int limit;
  final int total;
  const PaginatedConversations({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });
}
