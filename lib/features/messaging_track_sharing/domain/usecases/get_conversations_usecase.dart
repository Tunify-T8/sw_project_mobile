import '../entities/paginated_conversations.dart';
import '../repositories/messaging_repository.dart';

class GetConversationsUseCase {
  final MessagingRepository repo;
  const GetConversationsUseCase(this.repo);
  Future<PaginatedConversations> call({int page = 1, int limit = 20}) =>
      repo.getConversations(page: page, limit: limit);
}
