import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Jenis notifikasi yang tampil sebagai banner di bagian ATAS layar.
enum AppNotificationType {
  cartAdded,
  contactSeller,
  openMaps,
  warning,
  success,
  error,
  info;

  IconData get icon => switch (this) {
        AppNotificationType.cartAdded => Icons.shopping_bag_outlined,
        AppNotificationType.contactSeller => Icons.chat_bubble_outline_rounded,
        AppNotificationType.openMaps => Icons.map_outlined,
        AppNotificationType.warning => Icons.timer_off_outlined,
        AppNotificationType.success => Icons.check_circle_outline_rounded,
        AppNotificationType.error => Icons.error_outline_rounded,
        AppNotificationType.info => Icons.info_outline_rounded,
      };

  Color get accent => switch (this) {
        AppNotificationType.cartAdded => AppColors.statusOlive,
        AppNotificationType.contactSeller => AppColors.mocha,
        AppNotificationType.openMaps => AppColors.chipBrown,
        AppNotificationType.warning => AppColors.espresso,
        AppNotificationType.success => AppColors.statusOlive,
        AppNotificationType.error => AppColors.danger,
        AppNotificationType.info => AppColors.espresso,
      };

  Color get accentBackground => switch (this) {
        AppNotificationType.cartAdded => const Color(0xFFDDE6BC),
        AppNotificationType.contactSeller => const Color(0xFFF5EBE0),
        AppNotificationType.openMaps => const Color(0xFFF2E2D4),
        AppNotificationType.warning => const Color(0xFFF5EBE0),
        AppNotificationType.success => const Color(0xFFDDE6BC),
        AppNotificationType.error => const Color(0xFFFBDAD8),
        AppNotificationType.info => const Color(0xFFF1ECE4),
      };
}

/// Banner notifikasi ringan yang muncul di atas layar (bukan di bawah),
/// lalu hilang sendiri. Semua notifikasi aplikasi lewat sini supaya
/// tampilannya konsisten.
class AppNotification {
  AppNotification._();

  static OverlayEntry? _current;

  static void _removeCurrent() {
    final entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _removeCurrent();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (!entry.mounted) return;
          entry.remove();
          if (identical(_current, entry)) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  /// "Yap Latte (Reguler, Less Sugar) ditambahkan ke keranjang."
  static void cartAdded(
    BuildContext context, {
    required String itemName,
    String? variant,
  }) {
    show(
      context,
      title: 'Ditambahkan ke keranjang',
      message: variant == null ? itemName : '$itemName · $variant',
      type: AppNotificationType.cartAdded,
    );
  }

  static void contactSeller(BuildContext context) {
    show(
      context,
      title: 'Menghubungi penjual',
      message: 'Membuka WhatsApp Yap Coffee...',
      type: AppNotificationType.contactSeller,
    );
  }

  static void openMaps(BuildContext context) {
    show(
      context,
      title: 'Membuka Google Maps',
      message: 'Menampilkan rute menuju titik pengambilan.',
      type: AppNotificationType.openMaps,
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: AppNotificationType.success,
    );
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(
      context,
      title: title,
      message: message,
      type: AppNotificationType.warning,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: AppNotificationType.error,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: AppNotificationType.info,
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.title,
  });

  final String message;
  final String? title;
  final AppNotificationType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _controller,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardLine),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.type.accentBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.type.icon,
                            size: 19,
                            color: widget.type.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.title != null)
                                Text(
                                  widget.title!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              Text(
                                widget.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
