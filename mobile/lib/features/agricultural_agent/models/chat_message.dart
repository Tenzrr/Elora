enum MessageSender { assistant, user }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.toolsExecuted = const [],
  });

  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String> toolsExecuted;
}
