import 'package:flutter/material.dart';

import 'core/navigation/app_navigation.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/forgot_password_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/new_password_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/home/presentation/main_shell_page.dart';

class YapCoffeeApp extends StatelessWidget {
  const YapCoffeeApp({super.key, required this.initialRoute});

  final String initialRoute;

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      case AppRoutes.login:
        page = const LoginPage();
      case AppRoutes.register:
        page = const RegisterPage();
      case AppRoutes.forgotPassword:
        page = const ForgotPasswordPage();
      case AppRoutes.newPassword:
        final args = settings.arguments;
        if (args is! NewPasswordArgs) return null;
        page = NewPasswordPage(args: args);
      case AppRoutes.home:
        page = const MainShellPage(initialIndex: 0);
      case AppRoutes.menu:
        page = const MainShellPage(initialIndex: 1);
      default:
        return null;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yap Coffee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
