/// Filter mode for the conversation list — drives the dropdown menu shown
/// from the Activity > Messages tab.
enum MessagesFilter {
  all,
  unreadOnly;

  String get label {
    switch (this) {
      case MessagesFilter.all:
        return 'All messages';
      case MessagesFilter.unreadOnly:
        return 'Unread only';
    }
  }
}
