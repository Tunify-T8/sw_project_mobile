import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/engagement_user_entity.dart';
import '../provider/enagement_providers.dart';
import '../provider/engagement_state.dart';
import '../utils/engagement_formatters.dart';

class RepostersScreen extends ConsumerStatefulWidget {
  const RepostersScreen({super.key, required this.trackId});

  final String trackId;

  @override
  ConsumerState<RepostersScreen> createState() => _RepostersScreenState();
}

class _RepostersScreenState extends ConsumerState<RepostersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementProvider(widget.trackId).notifier).loadReposters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final repostersCount = state.reposters.isNotEmpty
        ? state.reposters.length
        : state.engagement?.repostCount ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: const BackButton(color: Colors.white),
        title: Text(
          '$repostersCount Reposts',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EngagementState state) {
    if (state.repostersStatus == EngagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.repostersStatus == EngagementStatus.error) {
      return Center(
        child: Text(
          state.error ?? 'Something went wrong',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (state.reposters.isEmpty) {
      return const Center(
        child: Text(
          'No reposts yet',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Key: EngagementKeys.repostersList
    return ListView.builder(
      key: const Key('reposters_list'),
      itemCount: state.reposters.length,
      itemBuilder: (context, index) => _UserTile(user: state.reposters[index]),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final EngagementUserEntity user;

  @override
  Widget build(BuildContext context) {
    // Key: EngagementKeys.reposterTile (ValueKey per user)
    return ListTile(
      key: ValueKey('reposter_tile_${user.id}'),
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
      title: Text(
        user.displayName,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        // Handle tap on user tile
      },
    );
  }
}
