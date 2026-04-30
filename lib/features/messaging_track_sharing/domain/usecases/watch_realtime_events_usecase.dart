import '../entities/realtime_event.dart';
import '../repositories/messaging_repository.dart';
class WatchRealtimeMessagingEventsUseCase {
  final MessagingRepository repo;
  const WatchRealtimeMessagingEventsUseCase(this.repo);
  Stream<RealtimeMessagingEvent> call() => repo.realtimeEvents();
}
