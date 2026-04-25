import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/shared_track_link_opener.dart';

class OpenSharedTrackLinkScreen extends ConsumerStatefulWidget {
  const OpenSharedTrackLinkScreen({super.key});

  @override
  ConsumerState<OpenSharedTrackLinkScreen> createState() =>
      _OpenSharedTrackLinkScreenState();
}

class _OpenSharedTrackLinkScreenState
    extends ConsumerState<OpenSharedTrackLinkScreen> {
  late final TextEditingController _controller;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadClipboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadClipboard() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboard?.text?.trim();
    if (!mounted || text == null || text.isEmpty) return;
    if (parseTrackShareLink(text) == null) return;
    _controller.text = text;
  }

  Future<void> _open() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);

    final opened = await openSharedTrackLink(
      context,
      ref,
      _controller.text,
      replaceCurrentRoute: true,
    );

    if (!mounted) return;
    setState(() => _isOpening = false);
    if (!opened) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Open shared link'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _open(),
                decoration: const InputDecoration(
                  hintText: 'https://tunify.duckdns.org/tracks/...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _isOpening ? null : _open,
                child: _isOpening
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
