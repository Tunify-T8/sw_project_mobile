import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'track_option_menu_item.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../../features/engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../../features/engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import '../../../../core/utils/navigation_utils.dart';

class TrackSocialActions extends ConsumerWidget {
  final String trackId;
  final String artistId;
  final String title;
  final String artistName;
  final String? coverUrl;
  final bool isReposted;

  const TrackSocialActions({
    super.key,
    required this.trackId,
    required this.artistId,
    required this.title,
    required this.artistName,
    required this.coverUrl,
    required this.isReposted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        /// Go to profile
        TrackOptionMenuItem(
          icon: Icons.person_outline,
          label: 'Go to profile',
          onTap: () {
            final navigator = Navigator.of(context);
            final targetContext = navigator.context;
            navigator.pop();
            navigateToProfile(
              targetContext,
              artistId,
              currentUserId: ref.read(authControllerProvider).value?.id,
            );
          },
        ),

        /// Comments
        TrackOptionMenuItem(
          key: const Key('track_options_comment_item'),
          icon: Icons.comment_outlined,
          label: 'View comments',
          onTap: () {
            final navigator = Navigator.of(context);
            navigator.pop();
            navigator.push(
              MaterialPageRoute(
                builder: (_) => CommentsScreen(trackId: trackId),
              ),
            );
          },
        ),

        /// Repost
        TrackOptionMenuItem(
          key: const Key('track_options_repost_item'),
          icon: isReposted ? Icons.repeat_on : Icons.repeat,
          label: isReposted ? 'Reposted' : 'Repost on SoundCloud',
          color: isReposted ? Colors.orange : Colors.white,
          onTap: () {
            final navigator = Navigator.of(context);
            final targetContext = navigator.context;
            navigator.pop();

            if (isReposted) {
              ref.read(engagementProvider(trackId).notifier).removeRepost();
              return;
            }

            RepostCaptionSheet.show(
              targetContext,
              trackId: trackId,
              trackTitle: title,
              artistName: artistName,
              coverUrl: coverUrl,
            );
          },
        ),
      ],
    );
  }
}
