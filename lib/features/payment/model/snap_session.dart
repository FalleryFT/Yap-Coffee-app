/// Hasil POST /api/orders/:code/snap: alamat halaman bayar Midtrans (Snap) untuk WebView.
class SnapSession {
  const SnapSession({
    required this.redirectUrl,
    required this.finishUrl,
    required this.secondsLeft,
  });

  /// Halaman pembayaran Midtrans yang dibuka di WebView.
  final String redirectUrl;

  /// Setelah pelanggan selesai, Midtrans mengarahkan WebView ke alamat ini.
  /// Aplikasi mencegat alamat ini lalu menutup WebView.
  final String finishUrl;

  final int secondsLeft;

  factory SnapSession.fromJson(Map<String, dynamic> json) => SnapSession(
        redirectUrl: json['redirectUrl'] as String,
        finishUrl: json['finishUrl'] as String,
        secondsLeft: (json['secondsLeft'] as num?)?.toInt() ?? 0,
      );
}
