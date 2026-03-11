class TrackMetadataState {
  final String title;
  final String genre;
  final String description;
  final String tags; // not in actual app but in reqs
  final String privacy; // check if enum or not (public / private)
  final bool isSaving; 
  final String? error;
  // button replace missing -> open file picker again to replace the file and restart the upload process
  // placeholder for premium->artist pro can make u schedule release date and time
  //caption not here -> maybe instead of tags
// image not here -> need image picker.
//artist name not here -> get from user profile
//=====================================
//DONT FORGET THE OTHER TABS ADVANCED AND PERMISSIONS 
//=====================================

  const TrackMetadataState({
    this.title = '',
    this.genre = '',
    this.description = '',
    this.tags = '',
    this.privacy = 'public',
    this.isSaving = false,
    this.error,
  });

  TrackMetadataState copyWith({
    String? title,
    String? genre,
    String? description,
    String? tags,
    String? privacy,
    bool? isSaving,
    String? error,
  }) {
    return TrackMetadataState(
      title: title ?? this.title,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      privacy: privacy ?? this.privacy,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}