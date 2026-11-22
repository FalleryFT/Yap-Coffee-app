import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Avatar asisten chatbot: robot barista dari folder assets.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, this.size = 32, this.bordered = false});

  static const String assetPath = 'assets/images/Code_Generated_Image.png';

  final double size;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final image = ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.smart_toy_rounded,
            size: size * 0.7,
            color: AppColors.bark,
          ),
        ),
      ),
    );

    if (!bordered) return image;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.line),
      ),
      child: image,
    );
  }
}
