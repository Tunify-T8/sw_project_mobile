import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/upload_waveform_service.dart';
import '../../domain/entities/upload_item.dart';
import 'track_detail_waveform_source.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final trackDetailWaveformProvider = Provider.autoDispose
    .family<TrackDetailWaveformState, UploadItem>((ref, item) {
      return TrackDetailWaveformState(
        waveformUrl: resolveTrackDetailWaveformUrl(item),
        duration: Duration(seconds: item.durationSeconds),
      );
    });

/// Extracts real waveform bars from the audio file.
/// Returns null only when no audio source is available at all.
final trackDetailWaveformBarsProvider = FutureProvider.autoDispose
    .family<List<double>?, UploadItem>((ref, item) async {
      if (item.waveformBars != null && item.waveformBars!.isNotEmpty) {
        return item.waveformBars;
      }
      return _extractWaveformBars(item);
    });

// ── State ─────────────────────────────────────────────────────────────────────

class TrackDetailWaveformState {
  const TrackDetailWaveformState({
    required this.waveformUrl,
    required this.duration,
  });

  final String? waveformUrl;
  final Duration duration;

  bool get hasWaveform => waveformUrl != null;
}

String formatTrackDetailDuration(Duration value) {
  final minutes = value.inMinutes;
  final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

final UploadWaveformService _waveformService = UploadWaveformService();

// ── URL resolution ────────────────────────────────────────────────────────────

String? resolveTrackDetailWaveformUrl(UploadItem item) {
  final derived = _deriveCloudinaryWaveformUrl(item.audioUrl);
  if (derived != null) return derived;
  final raw = item.waveformUrl?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return null;
}

String? _deriveCloudinaryWaveformUrl(String? audioUrl) {
  final url = audioUrl?.trim();
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.host.contains('res.cloudinary.com')) return null;
  const marker = '/video/upload/';
  final idx = url.indexOf(marker);
  if (idx < 0) return null;
  final prefix = url.substring(0, idx + marker.length);
  final asset = url.substring(idx + marker.length);
  final dot = asset.lastIndexOf('.');
  if (dot <= 0) return null;
  final pub = asset.substring(0, dot);
  return '${prefix}fl_waveform,w_1600,h_320,c_fit,co_rgb:ffffff/$pub.png';
}

// ── Extraction ────────────────────────────────────────────────────────────────

Future<List<double>?> _extractWaveformBars(UploadItem item) async {
  if (kIsWeb) return null;
  if (!Platform.isAndroid && !Platform.isIOS) return null;

  final sourcePath = await resolveTrackDetailWaveformSource(item);
  if (sourcePath == null) return null;

  return _waveformService.generateDisplayBarsFromFile(
    sourcePath,
    targetBarCount: 180,
  );
}
