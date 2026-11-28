import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/navigation/app_navigation.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';
import 'features/auth/view/forgot_password_page.dart';
import 'features/auth/view/login_page.dart';
import 'features/auth/view/new_password_page.dart';
import 'features/auth/view/register_page.dart';
import 'features/cart/view/cart_page.dart';
import 'features/home/view/main_shell_page.dart';

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
      case AppRoutes.cart:
        page = const CartPage();
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
      // Urutan dari luar ke dalam: batasi skala teks, hitung breakpoint dari
      // lebar jendela asli, lalu pusatkan konten selebar ponsel.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: AppLayout.textScalerFor(mediaQuery),
          ),
          child: ResponsiveBreakpoints.builder(
            breakpoints: AppLayout.breakpoints,
            child: ColoredBox(
              color: AppLayout.backdropColor,
              child: MaxWidthBox(
                maxWidth: AppLayout.maxContentWidth,
                backgroundColor: AppColors.cream,
                // Sentuh area kosong di halaman mana pun untuk menutup keyboard.
                // Tombol, kolom teks, dan daftar yang bisa di-scroll tetap
                // bekerja normal karena gesture anak selalu menang.
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}