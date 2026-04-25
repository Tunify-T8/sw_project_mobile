import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/block_conversation_usecase.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_conversation_read_usecase.dart';
import '../../domain/usecases/open_conversation_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/watch_realtime_events_usecase.dart';
import 'messaging_repository_provider.dart';

final getConversationsUseCaseProvider = Provider(
    (ref) => GetConversationsUseCase(ref.watch(messagingRepositoryProvider)));
final getMessagesUseCaseProvider = Provider(
    (ref) => GetMessagesUseCase(ref.watch(messagingRepositoryProvider)));
final sendMessageUseCaseProvider = Provider(
    (ref) => SendMessageUseCase(ref.watch(messagingRepositoryProvider)));
final markConversationReadUseCaseProvider = Provider((ref) =>
    MarkConversationReadUseCase(ref.watch(messagingRepositoryProvider)));
final openConversationUseCaseProvider = Provider(
    (ref) => OpenConversationUseCase(ref.watch(messagingRepositoryProvider)));
final getUnreadMessageCountUseCaseProvider = Provider((ref) =>
    GetUnreadMessageCountUseCase(ref.watch(messagingRepositoryProvider)));
final blockConversationUseCaseProvider = Provider(
    (ref) => BlockConversationUseCase(ref.watch(messagingRepositoryProvider)));
final deleteConversationUseCaseProvider = Provider(
    (ref) => DeleteConversationUseCase(ref.watch(messagingRepositoryProvider)));
final watchRealtimeMessagingEventsUseCaseProvider = Provider((ref) =>
    WatchRealtimeMessagingEventsUseCase(
        ref.watch(messagingRepositoryProvider)));
