import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repository/mock_messaging_repository_impl.dart';
import '../../data/repository/real_messaging_repository_impl.dart';
import '../../data/dto/user_preview_dto.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'messaging_backend_mode_provider.dart';
import 'messaging_dependencies_provider.dart';

/// Resolves the correct [MessagingRepository] based on the active backend mode.
///
/// Consumers must depend on [MessagingRepository] only — never on a concrete
/// implementation.
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final mode = ref.watch(messagingBackendModeProvider);
  final sessionUserId = ref.watch(messagingSessionUserIdProvider);

  if (mode == MessagingBackendMode.real) {
    return RealMessagingRepository(
      ref.watch(messagingApiProvider),
      ref.watch(messagingSocketProvider),
      currentUserId: () => sessionUserId,
      userPreviewResolver: (userId) async {
        final profile = await ref
            .read(profileRepositoryProvider)
            .getProfileById(userId);
        final displayName = (profile.displayName?.trim().isNotEmpty ?? false)
            ? profile.displayName!.trim()
            : profile.userName.trim();
        return UserPreviewDto(
          id: profile.id.trim().isNotEmpty ? profile.id : userId,
          displayName: displayName.isEmpty ? 'Unknown User' : displayName,
          avatarUrl: profile.profileImagePath,
        );
      },
    );
  }

  final authUser = ref.watch(authControllerProvider).asData?.value;
  final store = ref.watch(mockMessagingStoreProvider);
  store.syncCurrentUser(
    id: authUser?.id ?? 'mock-user-001',
    displayName: authUser?.username ?? 'You',
    avatarUrl: authUser?.avatarUrl,
  );

  return MockMessagingRepository(store, ref.watch(mockMessagingSocketProvider));
});
