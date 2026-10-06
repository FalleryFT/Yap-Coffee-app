import 'package:flutter/material.dart';

/// Kunci global agar interceptor Dio (di luar widget) bisa berpindah halaman,
/// misalnya saat sesi berakhir.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/new-password';
  static const String home = '/home';
}
