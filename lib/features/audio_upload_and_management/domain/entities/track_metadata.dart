class TrackMetadata {
  final String title;
  final String genreCategory;
  final String genreSubGenre;
  final List<String> tags; // not in actual app but in reqs
  final String description;
  final String privacy; // check if enum or not (public / private)
  final List<String> artists;
  final String? artworkPath;
  // button replace missing -> open file picker again to replace the file and restart the upload process
  // placeholder for premium->artist pro can make u schedule release date and time
  //caption not here -> maybe instead of tags
  // image not here -> need image picker.
  //artist name not here -> get from user profile
  //=====================================
  //DONT FORGET THE OTHER TABS ADVANCED AND PERMISSIONS
  //=====================================
  const TrackMetadata({
    required this.title,
    required this.genreCategory,
    required this.genreSubGenre,
    required this.tags,
    required this.description,
    required this.privacy,
    required this.artists,
    this.artworkPath,
  });
}
