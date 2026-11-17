import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';

class AssistantChatBubble extends StatelessWidget {
  const AssistantChatBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 64, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: EloraColors.ink,
          ),
        ),
      ),
    );
  }
}

class UserChatBubble extends StatelessWidget {
  const UserChatBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 64, right: 16, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF62BE8B),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFF1B3B28),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
