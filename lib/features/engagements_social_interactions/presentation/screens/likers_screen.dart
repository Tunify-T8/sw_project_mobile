import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: const BackButton(color: Colors.white),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (state.likersStatus == EngagementStatus.error) {
      return Center(
        child: Text(
          state.error ?? 'Something went wrong',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (state.likers.isEmpty) {
      return const Center(
        child: Text(
          'No likes yet',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.likers.length,
      itemBuilder: (context, index) => _UserTile(user: state.likers[index]),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final EngagementUserEntity user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white24,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                EngagementFormatters.initials(user.username),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Text(
        user.username,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}
