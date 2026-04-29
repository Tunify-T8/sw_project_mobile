import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/data/api/messaging_api.dart';
import 'package:software_project/features/messaging_track_sharing/data/dto/message_dto.dart';
import 'package:software_project/features/messaging_track_sharing/data/repository/real_messaging_repository_impl.dart';
import 'package:software_project/features/messaging_track_sharing/data/services/messaging_socket.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_attachment.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/realtime_event.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/send_message_draft.dart';

void main() {
  test('unarchive uses the backend delete archive endpoint', () async {
    final dio = _RecordingDio();
    final api = MessagingApi(dio);

    await api.unarchive('conversation-1');

    expect(dio.requests, hasLength(1));
    expect(dio.requests.single.method, 'DELETE');
    expect(dio.requests.single.path, '/conversations/conversation-1/archive');
  });

  test('sends each track attachment separately before the text', () async {
    final socket = _RecordingMessagingSocket();
    final repository = RealMessagingRepository(
      MessagingApi(Dio()),
      socket,
      currentUserId: () => 'me',
    );

    await repository.sendMessage(
      'conversation-1',
      const SendMessageDraft(
        type: MessageType.attachment,
        text: 'listen to these',
        attachments: [
          MessageAttachment(
            id: 'track-1',
            type: MessageAttachmentType.track,
            backendKind: MessageAttachmentBackendKind.trackUpload,
            title: 'First track',
          ),
          MessageAttachment(
            id: 'track-2',
            type: MessageAttachmentType.track,
            backendKind: MessageAttachmentBackendKind.trackLike,
            title: 'Second track',
          ),
        ],
      ),
    );

    expect(socket.sent, hasLength(3));
    expect(socket.sent[0]['type'], 'TRACK_LIKE');
    expect(socket.sent[0]['trackId'], 'track-1');
    expect(socket.sent[0], isNot(contains('collectionId')));
    expect(socket.sent[1]['type'], 'TRACK_LIKE');
    expect(socket.sent[1]['trackId'], 'track-2');
    expect(socket.sent[2], {
      'conversationId': 'conversation-1',
      'type': 'TEXT',
      'content': 'listen to these',
    });
  });

  test('uses backend attachment types for collections and users', () async {
    final socket = _RecordingMessagingSocket();
    final repository = RealMessagingRepository(
      MessagingApi(Dio()),
      socket,
      currentUserId: () => 'me',
    );

    await repository.sendMessage(
      'conversation-1',
      const SendMessageDraft(
        type: MessageType.attachment,
        attachments: [
          MessageAttachment(
            id: 'playlist-1',
            type: MessageAttachmentType.collection,
            backendKind: MessageAttachmentBackendKind.playlist,
            title: 'Playlist',
          ),
          MessageAttachment(
            id: 'album-1',
            type: MessageAttachmentType.collection,
            backendKind: MessageAttachmentBackendKind.album,
            title: 'Album',
          ),
          MessageAttachment(
            id: 'user-1',
            type: MessageAttachmentType.user,
            backendKind: MessageAttachmentBackendKind.user,
            title: 'User',
          ),
        ],
      ),
    );

    expect(socket.sent, hasLength(3));
    expect(socket.sent[0]['type'], 'PLAYLIST');
    expect(socket.sent[0]['collectionId'], 'playlist-1');
    expect(socket.sent[1]['type'], 'ALBUM');
    expect(socket.sent[1]['collectionId'], 'album-1');
    expect(socket.sent[2]['type'], 'USER');
    expect(socket.sent[2]['userId'], 'user-1');
  });
}

class _RecordedRequest {
  const _RecordedRequest(this.method, this.path);

  final String method;
  final String path;
}

class _RecordingDio extends Dio {
  final requests = <_RecordedRequest>[];

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    requests.add(_RecordedRequest('DELETE', path));
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    requests.add(_RecordedRequest('POST', path));
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }
}

class _RecordingMessagingSocket implements MessagingSocket {
  final sent = <Map<String, dynamic>>[];
  final _controller = StreamController<RealtimeMessagingEvent>.broadcast();

  @override
  Stream<RealtimeMessagingEvent> get events => _controller.stream;

  @override
  bool get isConnected => true;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  Future<void> markMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async {}

  @override
  Future<void> markMessageRead({
    required String conversationId,
    required String messageId,
  }) async {}

  @override
  Future<MessageDto> sendMessage(Map<String, dynamic> payload) async {
    sent.add(Map<String, dynamic>.from(payload));
    return MessageDto.fromJson({
      'id': 'message-${sent.length}',
      'conversationId': payload['conversationId'],
      'senderId': 'me',
      'type': payload['type'],
      if (payload['content'] != null) 'content': payload['content'],
      if (payload['trackId'] != null)
        'attachment': {
          'id': payload['trackId'],
          'type': payload['type'],
          'preview': payload['clientPreview'],
        },
      if (payload['collectionId'] != null)
        'attachment': {
          'id': payload['collectionId'],
          'type': payload['type'],
          'preview': payload['clientPreview'],
        },
      if (payload['userId'] != null)
        'attachment': {
          'id': payload['userId'],
          'type': payload['type'],
          'preview': payload['clientPreview'],
        },
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'read': true,
    });
  }

  @override
  void startTyping(String conversationId) {}

  @override
  void stopTyping(String conversationId) {}
}
