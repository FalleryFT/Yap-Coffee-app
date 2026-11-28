import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Paksa ukuran teks 150% untuk menguji tata letak dengan font perangkat besar.
/// Hanya berlaku di mode debug. Kembalikan ke `false` setelah pengujian.
const bool kForceLargeText = false;

/// Ukuran kerangka aplikasi. Nilai di sini dipakai di seluruh aplikasi, jadi
/// mengubah lebar konten maksimal cukup di satu tempat.
abstract final class AppLayout {
  /// Lebar konten maksimal. Di layar lebar (web/laptop) aplikasi tampil di
  /// tengah selebar ponsel, bukan melar mengikuti jendela.
  static const double maxContentWidth = 480;

  /// Batas skala teks. Pengaturan font besar di HP (mis. 1.3-2.0) dipotong ke
  /// [maxTextScaleFactor] supaya tidak memicu overflow tata letak.
  static const double minTextScaleFactor = 0.9;
  static const double maxTextScaleFactor = 1.2;
  static const double forcedTextScaleFactor = 1.5;

  /// Batas breakpoint (inklusif pada angka batasnya).
  static const double compactBreakpoint = 450;
  static const double tabletBreakpoint = 800;
  static const double desktopBreakpoint = 1920;

  /// Nama breakpoint untuk layar di atas 1920 px.
  static const String wideBreakpoint = '4K';

  /// Warna area di luar konten pada layar lebar: krem yang lebih gelap dari
  /// [AppColors.cream] agar batas "ponsel" terlihat.
  static const Color backdropColor = Color(0xFFEDE7DD);

  static const List<Breakpoint> breakpoints = [
    Breakpoint(start: 0, end: compactBreakpoint, name: MOBILE),
    Breakpoint(
      start: compactBreakpoint + 1,
      end: tabletBreakpoint,
      name: TABLET,
    ),
    Breakpoint(
      start: tabletBreakpoint + 1,
      end: desktopBreakpoint,
      name: DESKTOP,
    ),
    Breakpoint(
      start: desktopBreakpoint + 1,
      end: double.infinity,
      name: wideBreakpoint,
    ),
  ];

  /// Skala teks yang dipakai aplikasi: dibatasi 0.9-1.2, atau dipaksa 1.5
  /// saat [kForceLargeText] aktif di mode debug.
  static TextScaler textScalerFor(MediaQueryData mediaQuery) {
    if (kDebugMode && kForceLargeText) {
      return const TextScaler.linear(forcedTextScaleFactor);
    }
    return mediaQuery.textScaler.clamp(
      minScaleFactor: minTextScaleFactor,
      maxScaleFactor: maxTextScaleFactor,
    );
  }
}

/// Pembungkus tipis [ResponsiveBreakpoints.of] supaya view tidak perlu
/// mengimpor package responsive_framework di banyak tempat.
///
/// Dipanggil hanya di dalam `build`; bila tidak ada [ResponsiveBreakpoints]
/// di atasnya (mis. widget diuji sendirian), lebar dari [MediaQuery] dipakai.
extension AppResponsiveContext on BuildContext {
  ResponsiveBreakpointsData? get _responsiveData =>
      dependOnInheritedWidgetOfExactType<InheritedResponsiveBreakpoints>()
          ?.data;

  /// Lebar jendela menurut breakpoint (bukan lebar konten yang sudah dibatasi).
  double get screenWidth =>
      _responsiveData?.screenWidth ?? MediaQuery.sizeOf(this).width;

  /// Nama breakpoint aktif: MOBILE, TABLET, DESKTOP, atau '4K'.
  String? get breakpointName => _responsiveData?.breakpoint.name;

  bool get isCompact => screenWidth <= AppLayout.compactBreakpoint;

  bool get isTablet =>
      screenWidth > AppLayout.compactBreakpoint &&
      screenWidth <= AppLayout.tabletBreakpoint;

  bool get isDesktop => screenWidth > AppLayout.tabletBreakpoint;
}
