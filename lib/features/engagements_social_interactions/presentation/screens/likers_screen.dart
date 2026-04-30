import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/ui/patterns/error_retry_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/engagement_user_entity.dart';
import '../provider/enagement_providers.dart';
import '../provider/engagement_state.dart';
import '../utils/engagement_formatters.dart';

class LikersScreen extends ConsumerStatefulWidget {
  const LikersScreen({super.key, required this.trackId});

  final String trackId;

  @override
  ConsumerState<LikersScreen> createState() => _LikersScreenState();
}

class _LikersScreenState extends ConsumerState<LikersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementProvider(widget.trackId).notifier).loadLikers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final likeCount = state.likers.isNotEmpty
        ? state.likers.length
        : state.engagement?.likeCount ?? 0;

    return Scaffold(
      key: const Key('likers_screen'),
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: const BackButton(key: Key('likers_back_button'), color: Colors.white),
        title: Text(
          '$likeCount Likes',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EngagementState state) {
    if (state.likersStatus == EngagementStatus.loading) {
      return const Center(key: Key('likers_loading'), child: CircularProgressIndicator());
    }

    if (state.likersStatus == EngagementStatus.error) {
      return ErrorRetryView(
        key: const Key('likers_error'),
        onRetry: () => ref.read(engagementProvider(widget.trackId).notifier).loadLikers(),
      );
    }

    if (state.likers.isEmpty) {
      return const Center(
        key: Key('likers_empty'),
        child: Text(
          'No likes yet',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Key: EngagementKeys.likersList
    return ListView.builder(
      key: const Key('likers_list'),
      itemCount: state.likers.length,
      itemBuilder: (context, index) => _UserTile(
        user: state.likers[index],
        currentUserId: ref.read(authControllerProvider).value?.id ?? '',
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.currentUserId});

  final EngagementUserEntity user;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    // Key: EngagementKeys.likerTile (ValueKey per user)
    return ListTile(
      key: ValueKey('liker_tile_${user.id}'),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white24,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                EngagementFormatters.initials(user.displayName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          if (user.isCertified) ...[
            const SizedBox(width: 5),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ],
      ),
      onTap: () {
        navigateToProfile(context, user.id, currentUserId: currentUserId);
      },
    );
  }
}
