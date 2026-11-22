import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'chat_avatar.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
    this.muted = false,
  });

  final String text;
  final bool isUser;
  final bool isError;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isUser
        ? Colors.white
        : isError
            ? AppColors.danger
            : (muted ? AppColors.textMuted : AppColors.textDark);

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.espresso : AppColors.statusBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          height: 1.35,
          fontStyle: muted ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ChatAvatar(size: 28, bordered: true),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}