import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';

class RepostButton extends ConsumerWidget {
  final String trackId;

  const RepostButton({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engagementProvider(trackId));
    final isReposted = state.engagement?.isReposted ?? false;
    final repostCount = state.engagement?.repostCount ?? 0;

    return Column(
      children: [
        IconButton(
          onPressed: () {
            final notifier = ref.read(engagementProvider(trackId).notifier);
            if (isReposted) {
              notifier.removeRepost();
            } else {
              notifier.repostTrack();
            }
          },
          icon: Icon(
            isReposted ? Icons.repeat_on : Icons.repeat,
            color: isReposted ? Colors.orange : Colors.white,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        Text(
          repostCount.toString(),
          style: TextStyle(
            color: isReposted ? Colors.orange : Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
