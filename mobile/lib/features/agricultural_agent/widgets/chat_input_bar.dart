import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    this.onAttach,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFFD6E3DC),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: EloraColors.muted,
                  size: 22,
                ),
                tooltip: 'Attach photo',
                onPressed: widget.enabled ? widget.onAttach : null,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: const InputDecoration(
                    hintText: 'Ask your garden assistant...',
                    hintStyle: TextStyle(
                      color: EloraColors.muted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: EloraColors.deepGreen,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: 'Send message',
                  onPressed: widget.enabled ? _handleSubmit : null,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'A little AI help for a happier garden.',
            style: TextStyle(
              fontSize: 11,
              color: EloraColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}
