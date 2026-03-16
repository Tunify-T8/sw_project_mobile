import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_auth_guard.dart';
import 'track_metadata_screen.dart';

/// Entry point for the upload flow.
/// Auto-opens file picker on first render, creates draft, starts upload,
/// then navigates to TrackMetadataScreen.
class UploadEntryScreen extends ConsumerStatefulWidget {
  const UploadEntryScreen({super.key});

  @override
  ConsumerState<UploadEntryScreen> createState() => _UploadEntryScreenState();
}

class _UploadEntryScreenState extends ConsumerState<UploadEntryScreen> {
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_launched) return;
      _launched = true;

      final userId = ref.read(currentUploadUserIdProvider);
      await ref.read(uploadProvider.notifier).loadQuota(userId);
      await _startFlow();
    });
  }

  Future<void> _startFlow() async {
    final canUpload = await ensureUploadAuthenticated(context, ref);
    if (!canUpload) return;

    final userId = ref.read(currentUploadUserIdProvider);
    final track = await ref
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload(userId);

    if (!mounted) return;

    if (track == null) {
      // User cancelled picker — go back
      Navigator.of(context).maybePop();
      return;
    }

    final audioName = ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TrackMetadataScreen(
          trackId: track.trackId,
          fileName: audioName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: Color(0xFFFF5500),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.isLoadingQuota
                    ? 'Loading…'
                    : state.isPreparingUpload
                        ? 'Preparing…'
                        : state.isUploading
                            ? 'Starting upload…'
                            : 'Opening file picker…',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _startFlow,
                  child: const Text('Try again',
                      style: TextStyle(color: Color(0xFFFF5500), fontSize: 15)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
