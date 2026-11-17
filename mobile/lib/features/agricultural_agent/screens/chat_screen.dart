import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubbles.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    return Container(
      color: EloraColors.cream,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: EloraColors.deepGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: EloraColors.mint,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Garden assistant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: EloraColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '• AI powered • Here to help you grow',
                          style: TextStyle(
                            fontSize: 12,
                            color: EloraColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: EloraColors.ink),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Today, 9:41 AM',
                style: TextStyle(
                  fontSize: 12,
                  color: EloraColors.muted,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  if (msg.sender == MessageSender.user) {
                    return UserChatBubble(message: msg);
                  }
                  return AssistantChatBubble(message: msg);
                },
              ),
            ),
            if (chatState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thinking...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: EloraColors.muted,
                    ),
                  ),
                ),
              ),
            ChatInputBar(
              enabled: !chatState.isLoading,
              onSend: (text) =>
                  ref.read(chatProvider.notifier).sendMessage(text),
            ),
          ],
        ),
      ),
    );
  }
}
