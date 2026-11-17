import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Expanded(
              child: Center(
                child: Text('Chat messages'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
