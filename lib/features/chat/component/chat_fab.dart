import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../view/chat_page.dart';
import 'chat_avatar.dart';

class ChatFab extends StatelessWidget {
  /// Tooltip bawaan tombol. Dikosongkan saat tombol dipakai dengan tekan lama
  /// untuk menggeser, agar long press tidak memunculkan tooltip.
  final String? tooltip;

  const ChatFab({super.key, this.tooltip = 'Tanya asisten'});

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: 'Tanya asisten',
      child: Material(
        color: AppColors.buttonPeach,
        shape: const CircleBorder(),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatPage()),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: ChatAvatar(size: 32),
          ),
        ),
      ),
    );

    final message = tooltip;
    if (message == null) return button;
    return Tooltip(message: message, child: button);
  }
}
