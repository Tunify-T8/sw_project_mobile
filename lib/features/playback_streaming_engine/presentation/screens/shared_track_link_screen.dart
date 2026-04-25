import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/shared_track_link_opener.dart';

class SharedTrackLinkScreen extends ConsumerStatefulWidget {
  const SharedTrackLinkScreen({
    super.key,
    required this.trackId,
    this.privateToken,
  });

  final String trackId;
  final String? privateToken;

  @override
  ConsumerState<SharedTrackLinkScreen> createState() =>
      _SharedTrackLinkScreenState();
}

class _SharedTrackLinkScreenState extends ConsumerState<SharedTrackLinkScreen> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) return;
    _opened = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final opened = await openSharedTrack(
        context,
        ref,
        trackId: widget.trackId,
        privateToken: widget.privateToken,
        replaceCurrentRoute: true,
      );
      if (!mounted) return;
      if (!opened || Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
