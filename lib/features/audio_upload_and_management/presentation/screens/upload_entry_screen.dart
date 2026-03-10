import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upload_provider.dart';

class UploadEntryScreen extends ConsumerStatefulWidget {
  const UploadEntryScreen({super.key});

  @override
  ConsumerState<UploadEntryScreen> createState() => _UploadEntryScreenState();
}

class _UploadEntryScreenState extends ConsumerState<UploadEntryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(uploadProvider.notifier).loadQuota();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uploadState.isLoadingQuota)
                const CircularProgressIndicator()
              else ...[
                Text('Tier: ${uploadState.tier}'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Remaining upload minutes: ${uploadState.uploadMinutesRemaining}',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(uploadState.selectedFileName ?? 'No file selected'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(uploadProvider.notifier).selectFakeFile();
                },
                child: const Text('Select Fake File'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(uploadProvider.notifier).createAndUploadTrack();
                },
                child: const Text('Create & Upload Track'),
              ),
              const SizedBox(height: 20),
              Text('Track ID: ${uploadState.trackId ?? "-"}'),
              Text('Status: ${uploadState.status}'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: uploadState.progress),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Progress: ${(uploadState.progress * 100).toStringAsFixed(0)}%',
                ),
              ),
              if (uploadState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  uploadState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
