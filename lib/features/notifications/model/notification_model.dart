import '../../../core/utils/date_labels.dart';

/// Jenis notifikasi dari server (kolom `type`).
enum NotificationKind {
  orderReady,
  newMenu,
  other;

  static NotificationKind fromApi(String? value) => switch (value) {
        'order_ready' => NotificationKind.orderReady,
        'new_menu' => NotificationKind.newMenu,
        _ => NotificationKind.other,
      };
}

/// Satu notifikasi di kotak masuk aplikasi (GET /api/notifications → items).
class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.ref,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String body;

  /// orderReady → kode pesanan (WK-8493); newMenu → id menu.
  final String? ref;
  final bool read;

  /// 'YYYY-MM-DD HH:mm:ss' dari server.
  final String createdAt;

  String get timeLabel => DateLabels.dateTime(createdAt);

  factory InboxNotification.fromJson(Map<String, dynamic> json) {
    return InboxNotification(
      id: (json['id'] as num).toInt(),
      kind: NotificationKind.fromApi(json['type'] as String?),
      title: json['title'] as String,
      body: json['body'] as String,
      ref: json['ref'] as String?,
      read: json['read'] == true,
      createdAt: (json['createdAt'] as String?) ?? '',
    );
  }

  InboxNotification asRead() => InboxNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        ref: ref,
        read: true,
        createdAt: createdAt,
      );
}

/// Isi GET /api/notifications.
class InboxFeed {
  const InboxFeed({
    required this.items,
    required this.unreadCount,
    required this.enabled,
  });

  final List<InboxNotification> items;
  final int unreadCount;

  /// Saklar Notifikasi di Profil. Bila false, server tidak membuat notifikasi baru.
  final bool enabled;

  factory InboxFeed.fromJson(Map<String, dynamic> json) {
    return InboxFeed(
      items: (json['items'] as List)
          .map((e) => InboxNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unreadCount'] as num).toInt(),
      enabled: json['enabled'] == true,
    );
  }
}
