import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_view_mode.dart';

final feedViewModeProvider = NotifierProvider<FeedViewModeNotifier, FeedViewMode>(FeedViewModeNotifier.new);

class FeedViewModeNotifier extends Notifier<FeedViewMode> {
  @override
  FeedViewMode build() => FeedViewMode.discover;

  void setMode(FeedViewMode mode) => state = mode;
}