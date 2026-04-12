import '../entities/paginated_messages.dart';
import '../repositories/messaging_repository.dart';

class GetMessagesUseCase {
  final MessagingRepository repo;
  const GetMessagesUseCase(this.repo);
  Future<PaginatedMessages> call(String conversationId,
          {int page = 1, int limit = 20}) =>
      repo.getMessages(conversationId, page: page, limit: limit);
}
