/// Privacy level for a collection.
/// API returns lowercase "public" / "private".
enum CollectionPrivacy {
  public,
  private;

  String toJson() => name; // "public" | "private"

  static CollectionPrivacy fromJson(String raw) {
    return switch (raw.toLowerCase()) {
      'private' => CollectionPrivacy.private,
      _ => CollectionPrivacy.public,
    };
  }
}
