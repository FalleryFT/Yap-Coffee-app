import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../view/chat_page.dart';
import 'chat_avatar.dart';

class ChatFab extends StatelessWidget {
  /// Tooltip bawaan tombol. Dikosongkan saat tombol dipakai dengan geser,
  /// agar long press tidak memunculkan tooltip.
  final String? tooltip;

  /// Diameter tombol.
  final double size;

  const ChatFab({super.key, this.tooltip = 'Tanya asisten', this.size = 40});

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: 'Tanya asisten',
      hint: 'Geser untuk memindahkan tombol',
      child: Material(
        color: AppColors.buttonPeach,
        shape: const CircleBorder(),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatPage()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ChatAvatar(size: size - 8),
          ),
        ),
      ),
    );

    final message = tooltip;
    if (message == null) return button;
    return Tooltip(message: message, child: button);
  }
}