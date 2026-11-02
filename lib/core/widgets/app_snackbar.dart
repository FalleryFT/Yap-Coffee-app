import 'package:flutter/material.dart';

import 'app_notification.dart';

/// Notifikasi singkat. Sekarang tampil sebagai banner di ATAS layar
/// (lihat [AppNotification]) agar tidak tertutup tombol bawah.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  if (isError) {
    AppNotification.error(context, message);
  } else {
    AppNotification.success(context, message);
  }
}
