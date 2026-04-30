import '../entities/message_entity.dart';
import '../entities/send_message_draft.dart';
import '../repositories/messaging_repository.dart';

class SendMessageUseCase {
  final MessagingRepository repo;
  const SendMessageUseCase(this.repo);
  Future<MessageEntity> call(String conversationId, SendMessageDraft draft) =>
      repo.sendMessage(conversationId, draft);
}
