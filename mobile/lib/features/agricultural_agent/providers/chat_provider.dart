import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../models/chat_message.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.threadId,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? threadId;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? threadId,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      threadId: threadId ?? this.threadId,
      errorMessage: errorMessage,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          text: 'Hi there! What is growing in your garden today?',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text, {String? plantId}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: cleanText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final client = ref.read(apiProvider);
      final body = <String, dynamic>{
        'message': cleanText,
        if (state.threadId != null) 'thread_id': state.threadId,
        if (plantId != null) 'plant_id': plantId,
      };

      final response = await client.request(
        'POST',
        '/agricultural-agent/chat',
        body: body,
      );

      final replyText =
          response['response'] as String? ?? 'No response received.';
      final newThreadId = response['thread_id'] as String?;
      final tools = (response['tools_executed'] as List<dynamic>?)
              ?.map((t) => t['name'] as String)
              .toList() ??
          [];

      final assistantMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        text: replyText,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        toolsExecuted: tools,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
        threadId: newThreadId ?? state.threadId,
      );
    } catch (e) {
      final errorMsg = e is ApiException ? e.code : 'REQUEST_FAILED';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
