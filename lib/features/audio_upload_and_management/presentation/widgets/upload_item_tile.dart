import 'package:flutter/material.dart';

import '../../domain/entities/upload_item.dart';

class UploadItemTile extends StatelessWidget {
  const UploadItemTile({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onTap,
    required this.onEditTap,
    required this.onReplaceTap,
    required this.onDeleteTap,
  });

  final UploadItem item;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onReplaceTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = item.isDeleted ? Colors.white38 : Colors.white;
    final subtitleColor = item.isDeleted ? Colors.white24 : Colors.white70;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArtworkThumbnail(artworkUrl: item.artworkUrl),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.artistDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 17,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            item.durationLabel,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 17,
                            ),
                          ),
                          if (item.status != UploadProcessingStatus.finished) ...[
                            const SizedBox(width: 10),
                            _StatusChip(status: item.status),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                PopupMenuButton<_UploadAction>(
                  color: const Color(0xFF181818),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case _UploadAction.edit:
                        onEditTap();
                        break;
                      case _UploadAction.replace:
                        onReplaceTap();
                        break;
                      case _UploadAction.delete:
                        onDeleteTap();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<_UploadAction>(
                        value: _UploadAction.edit,
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem<_UploadAction>(
                        value: _UploadAction.replace,
                        child: Text(
                          'Replace file',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem<_UploadAction>(
                        value: _UploadAction.delete,
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _UploadAction {
  edit,
  replace,
  delete,
}

class _ArtworkThumbnail extends StatelessWidget {
  const _ArtworkThumbnail({
    required this.artworkUrl,
  });

  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          artworkUrl!,
          width: 82,
          height: 82,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _FallbackArtwork(),
        ),
      );
    }

    return const _FallbackArtwork();
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF96B7FF),
      ),
      child: const Icon(
        Icons.account_circle_rounded,
        color: Color(0xFF4872D7),
        size: 62,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final UploadProcessingStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (status) {
      case UploadProcessingStatus.processing:
        label = 'Processing';
        color = const Color(0xFFFFA726);
        break;
      case UploadProcessingStatus.failed:
        label = 'Failed';
        color = Colors.redAccent;
        break;
      case UploadProcessingStatus.deleted:
        label = 'Deleted';
        color = Colors.white38;
        break;
      case UploadProcessingStatus.finished:
        label = 'Ready';
        color = const Color(0xFF66BB6A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}