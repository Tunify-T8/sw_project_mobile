import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reposted_track_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import '../../../../shared/ui/patterns/error_message_view.dart';
import '../../../../shared/ui/patterns/error_retry_view.dart';
import '../../../../shared/ui/patterns/error_ui_mapper.dart';

class UserRepostsScreen extends ConsumerStatefulWidget {
  /// null → current user (GET /users/me/reposts)
  /// non-null → another user (GET /users/{userId}/reposts)
  const UserRepostsScreen({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<UserRepostsScreen> createState() => _UserRepostsScreenState();
}

class _UserRepostsScreenState extends ConsumerState<UserRepostsScreen> {
  List<RepostedTrackEntity> _tracks = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(getUserRepostsUsecaseProvider)
          .call(userId: widget.userId);
      if (mounted) setState(() { _tracks = tracks; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_tracks.length} Reposts',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
    }
    if (_error != null) {
      final uiError = mapToUiErrorState(_error!);
      if (uiError.retryable) return ErrorRetryView(onRetry: _load);
      return ErrorMessageView(message: uiError.message);
    }
    if (_tracks.isEmpty) {
      return const Center(
        child: Text(
          'No reposts yet',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tracks.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) => _RepostedTrackTile(track: _tracks[index]),
    );
  }
}

class _RepostedTrackTile extends StatelessWidget {
  const _RepostedTrackTile({required this.track});
  final RepostedTrackEntity track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: track.coverUrl != null
                ? Image.network(
                    track.coverUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  track.artistName,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 12, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text(
                      EngagementFormatters.compactCount(track.repostCount),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.play_arrow, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      EngagementFormatters.compactCount(track.playCount),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                EngagementFormatters.timeAgo(track.repostedAt),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                EngagementFormatters.timestamp(track.duration),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      color: Colors.white10,
      child: const Icon(Icons.music_note, color: Colors.white24, size: 26),
    );
  }
}
