import 'dart:io';

import 'package:flutter/material.dart';

class UploadArtworkView extends StatelessWidget {
  const UploadArtworkView({
    super.key,
    this.localPath,
    this.remoteUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    required this.placeholder,
  });

  final String? localPath;
  final String? remoteUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Widget placeholder;

  bool get _hasLocalFile =>
      localPath != null &&
      localPath!.isNotEmpty &&
      File(localPath!).existsSync();

  bool get _hasRemoteFile =>
      remoteUrl != null && remoteUrl!.trim().startsWith('http');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: ColoredBox(color: backgroundColor, child: _buildImage()),
      ),
    );
  }

  Widget _buildImage() {
    if (_hasLocalFile) {
      return Image.file(
        File(localPath!),
        fit: fit,
        width: width,
        height: height,
      );
    }

    if (_hasRemoteFile) {
      return Image.network(
        remoteUrl!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return placeholder;
  }
}
