const int kMaxMessageTextLength = 20000;

const String kMessageTextTooLongError =
    'Message text exceeds the 20,000 character limit.';

String trimmedMessageText(String? text) => (text ?? '').trim();

bool isMessageTextTooLong(String? text) =>
    trimmedMessageText(text).length > kMaxMessageTextLength;

void validateMessageTextLength(String? text) {
  if (isMessageTextTooLong(text)) {
    throw ArgumentError(kMessageTextTooLongError);
  }
}
