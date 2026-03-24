// Upload Feature Guide:
// Purpose: Owns the text editing controllers that mirror TrackMetadataState into the metadata form widgets.
// Used by: track_metadata_screen, track_metadata_body
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

import '../providers/track_metadata_state.dart';

class TrackMetadataFormControllers {
  final title = TextEditingController();
  final artist = TextEditingController();
  final description = TextEditingController();
  final caption = TextEditingController();
  final recordLabel = TextEditingController();
  final publisher = TextEditingController();
  final isrc = TextEditingController();
  final pLine = TextEditingController();
  final availabilityRegions = TextEditingController();

  void sync(TrackMetadataState state) {
    _sync(title, state.title);
    _sync(description, state.description);
    _sync(caption, state.tagsText);
    _sync(recordLabel, state.recordLabel);
    _sync(publisher, state.publisher);
    _sync(isrc, state.isrc);
    _sync(pLine, state.pLine);
    _sync(availabilityRegions, state.availabilityRegionsText);
  }

  void dispose() {
    title.dispose();
    artist.dispose();
    description.dispose();
    caption.dispose();
    recordLabel.dispose();
    publisher.dispose();
    isrc.dispose();
    pLine.dispose();
    availabilityRegions.dispose();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}
